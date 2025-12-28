// SmileBASIC Runtime - インタプリタ実行エンジン
import type { Program, Statement, Expression, LValue, Value, ArrayValue } from './ast';

// 配列メタデータ（次元情報保持）
interface ArrayMeta {
    data: ArrayValue;
    dims: number[];
}

export interface RuntimeState {
    variables: Map<string, Value>;
    arrays: Map<string, ArrayMeta>;
    textCursor: { x: number; y: number };
    textColor: number;
    running: boolean;
    breakFlag: boolean;
    returnValue: Value | undefined;
    dataPointer: number;
    dataValues: Value[];
}

export class Runtime {
    private ctx: CanvasRenderingContext2D;
    private textCtx: CanvasRenderingContext2D;
    private state: RuntimeState;
    private program: Program = { type: 'Program', body: [] };
    private labelMap: Map<string, number> = new Map();
    private subroutines: Map<string, Statement[]> = new Map();
    private keyState = 0;
    private keyPressed = 0;
    private lastKey = '';

    constructor(graphicsCanvas: HTMLCanvasElement, textCanvas: HTMLCanvasElement) {
        this.ctx = graphicsCanvas.getContext('2d')!;
        this.textCtx = textCanvas.getContext('2d')!;
        this.state = this.createInitialState();
        this.setupKeyboard();
    }

    private createInitialState(): RuntimeState {
        return {
            variables: new Map(),
            arrays: new Map(),
            textCursor: { x: 0, y: 0 },
            textColor: 0xFFFFFF,
            running: false,
            breakFlag: false,
            returnValue: undefined,
            dataPointer: 0,
            dataValues: [],
        };
    }

    private setupKeyboard() {
        const keyMap: Record<string, number> = {
            'ArrowUp': 1, 'ArrowDown': 2, 'ArrowLeft': 4, 'ArrowRight': 8,
            'KeyZ': 16, 'Enter': 16,
            'KeyX': 32, 'Backspace': 32,
            'KeyA': 64, 'KeyS': 128, 'KeyQ': 256, 'KeyW': 512,
        };
        window.addEventListener('keydown', (e) => {
            const bit = keyMap[e.code] || 0;
            if (bit) { this.keyPressed |= bit; this.keyState |= bit; e.preventDefault(); }
            this.lastKey = e.key.length === 1 ? e.key : '';
        });
        window.addEventListener('keyup', (e) => {
            const bit = keyMap[e.code] || 0;
            if (bit) this.keyState &= ~bit;
        });
    }

    load(program: Program) {
        this.program = program;
        this.state = this.createInitialState();
        this.labelMap.clear();
        this.subroutines.clear();

        // ラベルマップ構築
        let currentLabel: string | null = null;
        let currentBody: Statement[] = [];

        for (let i = 0; i < program.body.length; i++) {
            const stmt = program.body[i];
            if (stmt.type === 'Label') {
                if (currentLabel) {
                    this.subroutines.set(currentLabel, currentBody);
                }
                currentLabel = stmt.name;
                currentBody = [];
                this.labelMap.set(stmt.name, i);
            } else if (currentLabel) {
                currentBody.push(stmt);
            }

            // DATA文を収集
            if (stmt.type === 'Data') {
                for (const val of stmt.values) {
                    this.state.dataValues.push(this.evalExpr(val));
                }
            }
        }
        if (currentLabel) {
            this.subroutines.set(currentLabel, currentBody);
        }
    }

    async run() {
        this.state.running = true;
        await this.executeBlock(this.program.body);
        this.state.running = false;
    }

    stop() {
        this.state.running = false;
    }

    private async executeBlock(stmts: Statement[]): Promise<void> {
        for (const stmt of stmts) {
            if (!this.state.running) break;
            if (this.state.breakFlag) break;
            if (this.state.returnValue !== undefined) break;
            await this.execute(stmt);
        }
    }

    private async execute(stmt: Statement): Promise<void> {
        switch (stmt.type) {
            case 'Label':
            case 'Data':
                break;

            case 'Acls': this.acls(); break;
            case 'Vsync': await this.vsync(); break;
            case 'Break': this.state.breakFlag = true; break;
            case 'Return':
                this.state.returnValue = stmt.value ? this.evalExpr(stmt.value) : true;
                break;

            case 'VarDecl':
                this.state.variables.set(stmt.name, stmt.value ? this.evalExpr(stmt.value) : 0);
                break;

            case 'DimDecl': {
                for (const decl of stmt.declarations) {
                    if (decl.sizes.length === 0) {
                        // サイズなし変数宣言 (DIM X, Y, Z)
                        const defaultVal = decl.name.endsWith('$') ? '' : 0;
                        this.state.variables.set(decl.name, defaultVal);
                    } else {
                        // 配列宣言
                        const dims = decl.sizes.map(s => this.evalExpr(s) as number);
                        const total = dims.reduce((a, b) => a * b, 1) || 1;
                        const defaultVal = decl.name.endsWith('$') ? '' : 0;
                        this.state.arrays.set(decl.name, { data: new Array(total).fill(defaultVal), dims });
                    }
                }
                break;
            }

            case 'ConstDecl':
                this.state.variables.set(stmt.name, this.evalExpr(stmt.value));
                break;

            case 'Assignment':
                this.assign(stmt.target, this.evalExpr(stmt.value));
                break;

            case 'Print':
                this.print(stmt.args, stmt.newline);
                break;

            case 'Locate':
                this.state.textCursor.x = this.evalExpr(stmt.x) as number;
                this.state.textCursor.y = this.evalExpr(stmt.y) as number;
                break;

            case 'Color':
                this.state.textColor = this.evalExpr(stmt.color) as number;
                break;

            case 'Gfill':
                this.gfill(
                    this.evalExpr(stmt.x1) as number, this.evalExpr(stmt.y1) as number,
                    this.evalExpr(stmt.x2) as number, this.evalExpr(stmt.y2) as number,
                    this.evalExpr(stmt.color) as number
                );
                break;

            case 'Gline':
                this.gline(
                    this.evalExpr(stmt.x1) as number, this.evalExpr(stmt.y1) as number,
                    this.evalExpr(stmt.x2) as number, this.evalExpr(stmt.y2) as number,
                    this.evalExpr(stmt.color) as number
                );
                break;

            case 'Gbox':
                this.gbox(
                    this.evalExpr(stmt.x1) as number, this.evalExpr(stmt.y1) as number,
                    this.evalExpr(stmt.x2) as number, this.evalExpr(stmt.y2) as number,
                    this.evalExpr(stmt.color) as number
                );
                break;

            case 'Gcircle':
                this.gcircle(
                    this.evalExpr(stmt.x) as number, this.evalExpr(stmt.y) as number,
                    this.evalExpr(stmt.r) as number, this.evalExpr(stmt.color) as number,
                    stmt.fill ? !!this.evalExpr(stmt.fill) : false
                );
                break;

            case 'If':
                if (this.evalExpr(stmt.condition)) {
                    await this.executeBlock(stmt.thenBody);
                } else if (stmt.elseBody) {
                    await this.executeBlock(stmt.elseBody);
                }
                break;

            case 'For': {
                const start = this.evalExpr(stmt.start) as number;
                const end = this.evalExpr(stmt.end) as number;
                const step = stmt.step ? (this.evalExpr(stmt.step) as number) : 1;
                this.state.variables.set(stmt.variable, start);
                this.state.breakFlag = false;

                while (this.state.running && !this.state.breakFlag) {
                    const current = this.state.variables.get(stmt.variable) as number;
                    if (step > 0 && current > end) break;
                    if (step < 0 && current < end) break;
                    await this.executeBlock(stmt.body);
                    if (this.state.returnValue !== undefined) break;
                    this.state.variables.set(stmt.variable, current + step);
                }
                this.state.breakFlag = false;
                break;
            }

            case 'While':
                this.state.breakFlag = false;
                while (this.state.running && !this.state.breakFlag && this.evalExpr(stmt.condition)) {
                    await this.executeBlock(stmt.body);
                    if (this.state.returnValue !== undefined) break;
                }
                this.state.breakFlag = false;
                break;

            case 'Loop':
                this.state.breakFlag = false;
                while (this.state.running && !this.state.breakFlag) {
                    await this.executeBlock(stmt.body);
                    if (this.state.returnValue !== undefined) break;
                }
                this.state.breakFlag = false;
                break;

            case 'Gosub':
                await this.executeGosub(stmt.label);
                break;

            case 'OnGosub': {
                const idx = this.evalExpr(stmt.index) as number;
                if (idx >= 0 && idx < stmt.labels.length) {
                    await this.executeGosub(stmt.labels[idx]);
                }
                break;
            }

            case 'Inc': {
                const val = this.getLValue(stmt.target);
                this.assign(stmt.target, (val as number) + 1);
                break;
            }

            case 'Dec': {
                const val = this.getLValue(stmt.target);
                this.assign(stmt.target, (val as number) - 1);
                break;
            }

            case 'Beep':
                this.beep(stmt.sound ? (this.evalExpr(stmt.sound) as number) : 0);
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

            case 'ExpressionStmt':
                this.evalExpr(stmt.expression);
                break;
        }
    }

    private async executeGosub(label: string): Promise<Value> {
        const body = this.subroutines.get(label);
        if (!body) {
            console.warn(`Label not found: ${label}`);
            return false;
        }

        const prevReturn = this.state.returnValue;
        this.state.returnValue = undefined;

        for (const s of body) {
            if (!this.state.running) break;
            if (s.type === 'Return') {
                this.state.returnValue = s.value ? this.evalExpr(s.value) : true;
                break;
            }
            await this.execute(s);
            if (this.state.returnValue !== undefined) break;
        }

        const result = this.state.returnValue ?? true;
        this.state.returnValue = prevReturn;
        return result;
    }

    // ===== 式評価 =====

    private evalExpr(expr: Expression): Value {
        switch (expr.type) {
            case 'Number': return expr.value;
            case 'String': return expr.value;
            case 'Boolean': return expr.value;
            case 'Identifier': return this.state.variables.get(expr.name) ?? 0;
            case 'ArrayAccess': return this.getArrayValue(expr.name, expr.indices);
            case 'Binary': return this.evalBinary(expr.op, this.evalExpr(expr.left), this.evalExpr(expr.right));
            case 'Unary':
                const op = expr.op;
                const val = this.evalExpr(expr.operand);
                if (op === '-') return -(val as number);
                if (op === '!') return !val;
                return val;
            case 'Call': return this.evalCall(expr.name, expr.args);
            case 'GosubExpr':
                // 同期実行が必要なため、このコンテキストでは単純化
                const body = this.subroutines.get(expr.label);
                return body ? true : false;
        }
    }

    private evalBinary(op: string, left: Value, right: Value): Value {
        switch (op) {
            case '+':
                if (typeof left === 'string' || typeof right === 'string') return String(left) + String(right);
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

    private evalCall(name: string, args: Expression[]): Value {
        const upper = name.toUpperCase().replace(/[$!#]$/, '');
        const evalArgs = () => args.map(a => this.evalExpr(a));

        switch (upper) {
            case 'RND': return Math.floor(Math.random() * (evalArgs()[0] as number));
            case 'ABS': return Math.abs(evalArgs()[0] as number);
            case 'INT': case 'FLOOR': return Math.floor(evalArgs()[0] as number);
            case 'CEIL': return Math.ceil(evalArgs()[0] as number);
            case 'MIN': { const a = evalArgs(); return Math.min(a[0] as number, a[1] as number); }
            case 'MAX': { const a = evalArgs(); return Math.max(a[0] as number, a[1] as number); }
            case 'SIN': return Math.sin(evalArgs()[0] as number);
            case 'COS': return Math.cos(evalArgs()[0] as number);
            case 'SQRT': return Math.sqrt(evalArgs()[0] as number);
            case 'LEN': return String(evalArgs()[0]).length;
            case 'LEFT$': { const a = evalArgs(); return String(a[0]).substring(0, a[1] as number); }
            case 'RIGHT$': { const a = evalArgs(); const s = String(a[0]); return s.substring(s.length - (a[1] as number)); }
            case 'MID$': { const a = evalArgs(); return String(a[0]).substring(a[1] as number, (a[1] as number) + (a[2] as number)); }
            case 'STR$': return String(evalArgs()[0]);
            case 'VAL': return parseFloat(String(evalArgs()[0])) || 0;
            case 'CHR$': return String.fromCharCode(evalArgs()[0] as number);
            case 'ASC': return String(evalArgs()[0]).charCodeAt(0);
            case 'INSTR': { const a = evalArgs(); return String(a[0]).indexOf(String(a[1])); }
            case 'FORMAT$': return this.format(String(evalArgs()[0]), evalArgs()[1] as number);
            case 'BUTTON': {
                const mode = args.length > 0 ? (evalArgs()[0] as number) : 0;
                if (mode === 2) { const p = this.keyPressed; this.keyPressed = 0; return p; }
                return this.keyState;
            }
            case 'INKEY$': { const k = this.lastKey; this.lastKey = ''; return k; }
            case 'RGB': { const a = evalArgs(); return ((a[0] as number) << 16) | ((a[1] as number) << 8) | (a[2] as number); }
            case 'TIME$': return new Date().toLocaleTimeString('ja-JP', { hour12: false });
            case 'DATE$': return new Date().toLocaleDateString('ja-JP');
            default:
                console.warn(`Unknown function: ${name}`);
                return 0;
        }
    }

    private format(fmt: string, val: number): string {
        const match = fmt.match(/%(\.\d+)?f/);
        if (match) {
            const precision = match[1] ? parseInt(match[1].slice(1)) : 0;
            return val.toFixed(precision);
        }
        return String(val);
    }

    // ===== 配列操作 =====

    private getArrayValue(name: string, indices: Expression[]): Value {
        const arr = this.state.arrays.get(name);
        if (!arr) return 0;
        const idx = this.calcArrayIndex(arr.dims, indices);
        return arr.data[idx] ?? 0;
    }

    private setArrayValue(name: string, indices: Expression[], value: Value) {
        const arr = this.state.arrays.get(name);
        if (!arr) return;
        const idx = this.calcArrayIndex(arr.dims, indices);
        arr.data[idx] = value;
    }

    private calcArrayIndex(dims: number[], indices: Expression[]): number {
        const idxVals = indices.map(i => this.evalExpr(i) as number);
        let idx = 0;
        let multiplier = 1;
        for (let i = dims.length - 1; i >= 0; i--) {
            idx += (idxVals[i] || 0) * multiplier;
            multiplier *= dims[i];
        }
        return idx;
    }

    private getLValue(lv: LValue): Value {
        if (lv.type === 'Identifier') {
            return this.state.variables.get(lv.name) ?? 0;
        }
        return this.getArrayValue(lv.name, lv.indices);
    }

    private assign(target: LValue, value: Value) {
        if (target.type === 'Identifier') {
            this.state.variables.set(target.name, value);
        } else {
            this.setArrayValue(target.name, target.indices, value);
        }
    }

    // ===== 描画 =====

    private acls() {
        this.ctx.fillStyle = '#000000';
        this.ctx.fillRect(0, 0, 320, 240);
        this.textCtx.clearRect(0, 0, 320, 240);
        this.state.textCursor = { x: 0, y: 0 };
        this.state.textColor = 0xFFFFFF;
    }

    private colorToCSS(color: number): string {
        const r = (color >> 16) & 0xFF;
        const g = (color >> 8) & 0xFF;
        const b = color & 0xFF;
        return `rgb(${r},${g},${b})`;
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

    private print(args: Expression[], newline: boolean) {
        const text = args.map(a => String(this.evalExpr(a))).join('');
        const x = this.state.textCursor.x * 8;
        const y = this.state.textCursor.y * 8 + 8;

        this.textCtx.fillStyle = this.colorToCSS(this.state.textColor);
        this.textCtx.font = '8px monospace';
        this.textCtx.fillText(text, x, y);

        if (newline) {
            this.state.textCursor.y++;
            this.state.textCursor.x = 0;
        } else {
            this.state.textCursor.x += text.length;
        }
    }

    private beep(sound: number) {
        try {
            const audioCtx = new AudioContext();
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.frequency.value = 440 + sound * 100;
            gain.gain.value = 0.1;
            osc.start();
            osc.stop(audioCtx.currentTime + 0.1);
        } catch { }
    }

    private vsync(): Promise<void> {
        return new Promise(resolve => {
            requestAnimationFrame(() => resolve());
        });
    }
}
