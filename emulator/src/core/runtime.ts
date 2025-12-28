// SmileBASIC Runtime - 実行エンジン
import type { ProgramNode, StatementNode, ExpressionNode } from './parser';

export interface RuntimeState {
    variables: Map<string, number | string | boolean | (number | string | boolean)[]>;
    textCursor: { x: number; y: number };
    textColor: number;
    running: boolean;
    callStack: number[];
    dataPointer: number;
    dataValues: (number | string)[];
    breakFlag: boolean;
}

export class Runtime {
    private ctx: CanvasRenderingContext2D;
    private textCtx: CanvasRenderingContext2D;
    private state: RuntimeState;
    private program: ProgramNode;
    private currentStmt: number = 0;
    private subroutineMap: Map<string, StatementNode[]> = new Map();
    private keyState: number = 0;
    private keyPressed: number = 0;
    private lastKey: string = '';
    private frameCallback: (() => void) | null = null;

    constructor(
        graphicsCanvas: HTMLCanvasElement,
        textCanvas: HTMLCanvasElement
    ) {
        this.ctx = graphicsCanvas.getContext('2d')!;
        this.textCtx = textCanvas.getContext('2d')!;
        this.program = { type: 'Program', statements: [], labels: new Map() };
        this.state = this.createInitialState();
        this.setupKeyboardInput();
    }

    private createInitialState(): RuntimeState {
        return {
            variables: new Map(),
            textCursor: { x: 0, y: 0 },
            textColor: 0xFFFFFF,
            running: false,
            callStack: [],
            dataPointer: 0,
            dataValues: [],
            breakFlag: false,
        };
    }

    private setupKeyboardInput() {
        const keyMap: Record<string, number> = {
            'ArrowUp': 1, 'ArrowDown': 2, 'ArrowLeft': 4, 'ArrowRight': 8,
            'KeyZ': 16, 'Enter': 16,   // A button
            'KeyX': 32, 'Backspace': 32, // B button
            'KeyA': 64,  // X button
            'KeyS': 128, // Y button
            'KeyQ': 256, // L button
            'KeyW': 512, // R button
        };

        window.addEventListener('keydown', (e) => {
            const bit = keyMap[e.code] || 0;
            if (bit) {
                this.keyPressed |= bit;
                this.keyState |= bit;
                e.preventDefault();
            }
            this.lastKey = e.key.length === 1 ? e.key : '';
        });

        window.addEventListener('keyup', (e) => {
            const bit = keyMap[e.code] || 0;
            if (bit) {
                this.keyState &= ~bit;
            }
        });
    }

    load(program: ProgramNode) {
        this.program = program;
        this.state = this.createInitialState();
        this.currentStmt = 0;

        // DATAを収集
        for (const stmt of program.statements) {
            if (stmt.type === 'Data') {
                for (const val of stmt.values) {
                    const v = this.evalExpr(val);
                    this.state.dataValues.push(v as number | string);
                }
            }
        }

        // ラベルからサブルーチンを構築
        this.buildSubroutineMap();
    }

    private buildSubroutineMap() {
        let currentLabel: string | null = null;
        let currentBody: StatementNode[] = [];

        for (const stmt of this.program.statements) {
            if (stmt.type === 'Label') {
                if (currentLabel) {
                    this.subroutineMap.set(currentLabel, currentBody);
                }
                currentLabel = stmt.name;
                currentBody = [];
            } else if (currentLabel) {
                currentBody.push(stmt);
            }
        }
        if (currentLabel) {
            this.subroutineMap.set(currentLabel, currentBody);
        }
    }

    async run(onFrame?: () => void) {
        this.state.running = true;
        this.frameCallback = onFrame || null;
        this.currentStmt = 0;

        while (this.state.running && this.currentStmt < this.program.statements.length) {
            const stmt = this.program.statements[this.currentStmt];
            await this.executeStatement(stmt);
            this.currentStmt++;
        }

        this.state.running = false;
    }

    stop() {
        this.state.running = false;
    }

    private async executeStatement(stmt: StatementNode): Promise<void> {
        switch (stmt.type) {
            case 'OptionStrict':
                // 無視
                break;

            case 'Acls':
                this.acls();
                break;

            case 'Print':
                this.print(stmt.args);
                break;

            case 'Locate':
                this.state.textCursor.x = this.evalExpr(stmt.x) as number;
                this.state.textCursor.y = this.evalExpr(stmt.y) as number;
                break;

            case 'Color':
                this.state.textColor = this.evalExpr(stmt.color) as number;
                break;

            case 'GFill':
                this.gfill(
                    this.evalExpr(stmt.x1) as number,
                    this.evalExpr(stmt.y1) as number,
                    this.evalExpr(stmt.x2) as number,
                    this.evalExpr(stmt.y2) as number,
                    this.evalExpr(stmt.color) as number
                );
                break;

            case 'GLine':
                this.gline(
                    this.evalExpr(stmt.x1) as number,
                    this.evalExpr(stmt.y1) as number,
                    this.evalExpr(stmt.x2) as number,
                    this.evalExpr(stmt.y2) as number,
                    this.evalExpr(stmt.color) as number
                );
                break;

            case 'GBox':
                this.gbox(
                    this.evalExpr(stmt.x1) as number,
                    this.evalExpr(stmt.y1) as number,
                    this.evalExpr(stmt.x2) as number,
                    this.evalExpr(stmt.y2) as number,
                    this.evalExpr(stmt.color) as number
                );
                break;

            case 'GCircle':
                this.gcircle(
                    this.evalExpr(stmt.x) as number,
                    this.evalExpr(stmt.y) as number,
                    this.evalExpr(stmt.r) as number,
                    this.evalExpr(stmt.color) as number,
                    stmt.fill ? (this.evalExpr(stmt.fill) as boolean) : false
                );
                break;

            case 'VarDecl':
                if (stmt.value) {
                    this.state.variables.set(stmt.name, this.evalExpr(stmt.value));
                } else {
                    this.state.variables.set(stmt.name, 0);
                }
                break;

            case 'DimDecl':
                for (const decl of stmt.declarations) {
                    const sizes = decl.sizes.map(s => this.evalExpr(s) as number);
                    const size = sizes.reduce((a, b) => a * b, 1) || 1;
                    const arr = new Array(size).fill(decl.name.endsWith('$') ? '' : 0);
                    this.state.variables.set(decl.name, arr);
                }
                break;

            case 'ConstDecl':
                this.state.variables.set(stmt.name, this.evalExpr(stmt.value));
                break;

            case 'Assignment':
                this.assign(stmt.target, stmt.value);
                break;

            case 'If':
                await this.executeIf(stmt);
                break;

            case 'For':
                await this.executeFor(stmt);
                break;

            case 'While':
                await this.executeWhile(stmt);
                break;

            case 'Loop':
                await this.executeLoop(stmt);
                break;

            case 'Gosub':
                await this.executeGosub(stmt.label);
                break;

            case 'Return':
                // Gosub内で処理
                break;

            case 'OnGosub':
                const idx = this.evalExpr(stmt.index) as number;
                if (idx >= 0 && idx < stmt.labels.length) {
                    await this.executeGosub(stmt.labels[idx]);
                }
                break;

            case 'Inc':
                this.increment(stmt.variable, 1);
                break;

            case 'Dec':
                this.increment(stmt.variable, -1);
                break;

            case 'Beep':
                this.beep(stmt.sound ? this.evalExpr(stmt.sound) as number : 0);
                break;

            case 'Vsync':
                await this.vsync();
                break;

            case 'Break':
                this.state.breakFlag = true;
                break;

            case 'Read':
                for (const varName of stmt.variables) {
                    if (this.state.dataPointer < this.state.dataValues.length) {
                        this.state.variables.set(varName, this.state.dataValues[this.state.dataPointer++]);
                    }
                }
                break;

            case 'Restore':
                this.state.dataPointer = 0;
                break;

            case 'Label':
            case 'Data':
                // ラベルとDATAは実行時スキップ
                break;

            case 'ExpressionStatement':
                this.evalExpr(stmt.expression);
                break;
        }
    }

    private async executeIf(stmt: { type: 'If'; condition: ExpressionNode; thenBlock: StatementNode[]; elseBlock?: StatementNode[] }) {
        const cond = this.evalExpr(stmt.condition);
        const block = cond ? stmt.thenBlock : (stmt.elseBlock || []);
        for (const s of block) {
            if (!this.state.running) break;
            await this.executeStatement(s);
        }
    }

    private async executeFor(stmt: { type: 'For'; variable: string; start: ExpressionNode; end: ExpressionNode; step?: ExpressionNode; body: StatementNode[] }) {
        const start = this.evalExpr(stmt.start) as number;
        const end = this.evalExpr(stmt.end) as number;
        const step = stmt.step ? (this.evalExpr(stmt.step) as number) : 1;

        this.state.variables.set(stmt.variable, start);
        this.state.breakFlag = false;

        while (this.state.running && !this.state.breakFlag) {
            const current = this.state.variables.get(stmt.variable) as number;
            if (step > 0 && current > end) break;
            if (step < 0 && current < end) break;

            for (const s of stmt.body) {
                if (!this.state.running || this.state.breakFlag) break;
                await this.executeStatement(s);
            }

            this.state.variables.set(stmt.variable, current + step);
        }
        this.state.breakFlag = false;
    }

    private async executeWhile(stmt: { type: 'While'; condition: ExpressionNode; body: StatementNode[] }) {
        this.state.breakFlag = false;
        while (this.state.running && !this.state.breakFlag && this.evalExpr(stmt.condition)) {
            for (const s of stmt.body) {
                if (!this.state.running || this.state.breakFlag) break;
                await this.executeStatement(s);
            }
        }
        this.state.breakFlag = false;
    }

    private async executeLoop(stmt: { type: 'Loop'; body: StatementNode[] }) {
        this.state.breakFlag = false;
        while (this.state.running && !this.state.breakFlag) {
            for (const s of stmt.body) {
                if (!this.state.running || this.state.breakFlag) break;
                await this.executeStatement(s);
            }
        }
        this.state.breakFlag = false;
    }

    private async executeGosub(label: string) {
        const body = this.subroutineMap.get(label);
        if (!body) {
            console.warn(`Label not found: ${label}`);
            return;
        }

        for (const s of body) {
            if (!this.state.running) break;
            if (s.type === 'Return') break;
            await this.executeStatement(s);
        }
    }

    private assign(target: ExpressionNode, value: ExpressionNode) {
        const val = this.evalExpr(value);
        if (target.type === 'Identifier') {
            this.state.variables.set(target.name, val);
        } else if (target.type === 'ArrayAccess') {
            const arr = this.state.variables.get(target.array) as (number | string | boolean)[];
            const idx = this.evalExpr(target.indices[0]) as number;
            if (arr) arr[idx] = val;
        }
    }

    private increment(expr: ExpressionNode, delta: number) {
        if (expr.type === 'Identifier') {
            const val = (this.state.variables.get(expr.name) as number) || 0;
            this.state.variables.set(expr.name, val + delta);
        } else if (expr.type === 'ArrayAccess') {
            const arr = this.state.variables.get(expr.array) as number[];
            const idx = this.evalExpr(expr.indices[0]) as number;
            if (arr) arr[idx] = (arr[idx] || 0) + delta;
        }
    }

    private evalExpr(expr: ExpressionNode): number | string | boolean {
        switch (expr.type) {
            case 'Number':
                return expr.value;

            case 'String':
                return expr.value;

            case 'Boolean':
                return expr.value;

            case 'Identifier':
                return this.state.variables.get(expr.name) ?? 0;

            case 'ArrayAccess': {
                const arr = this.state.variables.get(expr.array) as (number | string | boolean)[];
                const idx = this.evalExpr(expr.indices[0]) as number;
                return arr ? arr[idx] : 0;
            }

            case 'BinaryOp': {
                const left = this.evalExpr(expr.left);
                const right = this.evalExpr(expr.right);
                return this.evalBinaryOp(expr.op, left, right);
            }

            case 'UnaryOp': {
                const operand = this.evalExpr(expr.operand);
                if (expr.op === '-') return -(operand as number);
                if (expr.op === '!') return !operand;
                return operand;
            }

            case 'FunctionCall':
                return this.evalFunction(expr.name, expr.args);
        }
    }

    private evalBinaryOp(op: string, left: number | string | boolean, right: number | string | boolean): number | string | boolean {
        switch (op) {
            case '+':
                if (typeof left === 'string' || typeof right === 'string') {
                    return String(left) + String(right);
                }
                return (left as number) + (right as number);
            case '-': return (left as number) - (right as number);
            case '*': return (left as number) * (right as number);
            case '/': return (left as number) / (right as number);
            case '%': return (left as number) % (right as number);
            case '==': return left === right;
            case '!=': return left !== right;
            case '<': return (left as number) < (right as number);
            case '>': return (left as number) > (right as number);
            case '<=': return (left as number) <= (right as number);
            case '>=': return (left as number) >= (right as number);
            case '&&': return left && right;
            case '||': return left || right;
            default: return 0;
        }
    }

    private evalFunction(name: string, args: ExpressionNode[]): number | string | boolean {
        const upperName = name.toUpperCase().replace(/[$!#]$/, '');
        const evalArgs = () => args.map(a => this.evalExpr(a));

        switch (upperName) {
            case 'RND': return Math.floor(Math.random() * (evalArgs()[0] as number));
            case 'ABS': return Math.abs(evalArgs()[0] as number);
            case 'INT': return Math.floor(evalArgs()[0] as number);
            case 'FLOOR': return Math.floor(evalArgs()[0] as number);
            case 'CEIL': return Math.ceil(evalArgs()[0] as number);
            case 'MIN': { const a = evalArgs(); return Math.min(a[0] as number, a[1] as number); }
            case 'MAX': { const a = evalArgs(); return Math.max(a[0] as number, a[1] as number); }
            case 'SIN': return Math.sin(evalArgs()[0] as number);
            case 'COS': return Math.cos(evalArgs()[0] as number);
            case 'LEN': return String(evalArgs()[0]).length;
            case 'LEFT$': { const a = evalArgs(); return String(a[0]).substring(0, a[1] as number); }
            case 'RIGHT$': { const a = evalArgs(); const s = String(a[0]); return s.substring(s.length - (a[1] as number)); }
            case 'MID$': { const a = evalArgs(); return String(a[0]).substring(a[1] as number, (a[1] as number) + (a[2] as number)); }
            case 'STR$': return String(evalArgs()[0]);
            case 'VAL': return parseFloat(String(evalArgs()[0])) || 0;
            case 'CHR$': return String.fromCharCode(evalArgs()[0] as number);
            case 'ASC': return String(evalArgs()[0]).charCodeAt(0);
            case 'INSTR': { const a = evalArgs(); return String(a[0]).indexOf(String(a[1])); }
            case 'FORMAT$': { const a = evalArgs(); return this.format(String(a[0]), a[1] as number); }
            case 'BUTTON': {
                const mode = args.length > 0 ? (evalArgs()[0] as number) : 0;
                if (mode === 2) {
                    const pressed = this.keyPressed;
                    this.keyPressed = 0;
                    return pressed;
                }
                return this.keyState;
            }
            case 'INKEY$': {
                const key = this.lastKey;
                this.lastKey = '';
                return key;
            }
            case 'RGB': { const a = evalArgs(); return ((a[0] as number) << 16) | ((a[1] as number) << 8) | (a[2] as number); }
            case 'TIME$': return new Date().toLocaleTimeString('ja-JP', { hour12: false });
            case 'DATE$': return new Date().toLocaleDateString('ja-JP');
            default:
                console.warn(`Unknown function: ${name}`);
                return 0;
        }
    }

    private format(fmt: string, val: number): string {
        // 簡易フォーマット実装
        const match = fmt.match(/%(\.\d+)?f/);
        if (match) {
            const precision = match[1] ? parseInt(match[1].slice(1)) : 0;
            return val.toFixed(precision);
        }
        return String(val);
    }

    // === 描画関数 ===

    private acls() {
        this.ctx.fillStyle = '#000000';
        this.ctx.fillRect(0, 0, 320, 240);
        this.textCtx.clearRect(0, 0, 320, 240);
        this.state.textCursor = { x: 0, y: 0 };
        this.state.textColor = 0xFFFFFF;
    }

    private colorToCSS(color: number): string {
        if (typeof color === 'number') {
            const r = (color >> 16) & 0xFF;
            const g = (color >> 8) & 0xFF;
            const b = color & 0xFF;
            return `rgb(${r},${g},${b})`;
        }
        return '#FFFFFF';
    }

    private gfill(x1: number, y1: number, x2: number, y2: number, color: number) {
        this.ctx.fillStyle = this.colorToCSS(color);
        this.ctx.fillRect(x1, y1, x2 - x1, y2 - y1);
    }

    private gline(x1: number, y1: number, x2: number, y2: number, color: number) {
        this.ctx.strokeStyle = this.colorToCSS(color);
        this.ctx.beginPath();
        this.ctx.moveTo(x1, y1);
        this.ctx.lineTo(x2, y2);
        this.ctx.stroke();
    }

    private gbox(x1: number, y1: number, x2: number, y2: number, color: number) {
        this.ctx.strokeStyle = this.colorToCSS(color);
        this.ctx.strokeRect(x1, y1, x2 - x1, y2 - y1);
    }

    private gcircle(x: number, y: number, r: number, color: number, fill: boolean) {
        this.ctx.beginPath();
        this.ctx.arc(x, y, r, 0, Math.PI * 2);
        if (fill) {
            this.ctx.fillStyle = this.colorToCSS(color);
            this.ctx.fill();
        } else {
            this.ctx.strokeStyle = this.colorToCSS(color);
            this.ctx.stroke();
        }
    }

    private print(args: ExpressionNode[]) {
        const text = args.map(a => String(this.evalExpr(a))).join('');
        const x = this.state.textCursor.x * 8;
        const y = this.state.textCursor.y * 8 + 8;

        this.textCtx.fillStyle = this.colorToCSS(this.state.textColor);
        this.textCtx.font = '8px monospace';
        this.textCtx.fillText(text, x, y);

        this.state.textCursor.y++;
    }

    private beep(sound: number) {
        // Web Audio APIで簡易ビープ音
        try {
            const audioCtx = new AudioContext();
            const oscillator = audioCtx.createOscillator();
            const gainNode = audioCtx.createGain();
            oscillator.connect(gainNode);
            gainNode.connect(audioCtx.destination);
            oscillator.frequency.value = 440 + sound * 100;
            gainNode.gain.value = 0.1;
            oscillator.start();
            oscillator.stop(audioCtx.currentTime + 0.1);
        } catch (e) {
            // オーディオ再生失敗は無視
        }
    }

    private vsync(): Promise<void> {
        return new Promise(resolve => {
            requestAnimationFrame(() => {
                if (this.frameCallback) this.frameCallback();
                resolve();
            });
        });
    }
}
