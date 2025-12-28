// SmileBASIC Parser - 構文解析
import type { Token, TokenType } from './lexer';

export type ASTNode =
    | ProgramNode
    | StatementNode
    | ExpressionNode;

export interface ProgramNode {
    type: 'Program';
    statements: StatementNode[];
    labels: Map<string, number>;
}

export type StatementNode =
    | { type: 'Acls' }
    | { type: 'Print'; args: ExpressionNode[] }
    | { type: 'Locate'; x: ExpressionNode; y: ExpressionNode }
    | { type: 'Color'; color: ExpressionNode }
    | { type: 'GFill'; x1: ExpressionNode; y1: ExpressionNode; x2: ExpressionNode; y2: ExpressionNode; color: ExpressionNode }
    | { type: 'GLine'; x1: ExpressionNode; y1: ExpressionNode; x2: ExpressionNode; y2: ExpressionNode; color: ExpressionNode }
    | { type: 'GBox'; x1: ExpressionNode; y1: ExpressionNode; x2: ExpressionNode; y2: ExpressionNode; color: ExpressionNode }
    | { type: 'GCircle'; x: ExpressionNode; y: ExpressionNode; r: ExpressionNode; color: ExpressionNode; fill?: ExpressionNode }
    | { type: 'VarDecl'; name: string; value?: ExpressionNode; isArray?: boolean; size?: ExpressionNode }
    | { type: 'DimDecl'; declarations: { name: string; sizes: ExpressionNode[] }[] }
    | { type: 'ConstDecl'; name: string; value: ExpressionNode }
    | { type: 'Assignment'; target: ExpressionNode; value: ExpressionNode }
    | { type: 'If'; condition: ExpressionNode; thenBlock: StatementNode[]; elseBlock?: StatementNode[] }
    | { type: 'For'; variable: string; start: ExpressionNode; end: ExpressionNode; step?: ExpressionNode; body: StatementNode[] }
    | { type: 'While'; condition: ExpressionNode; body: StatementNode[] }
    | { type: 'Loop'; body: StatementNode[] }
    | { type: 'Gosub'; label: string }
    | { type: 'Return' }
    | { type: 'OnGosub'; index: ExpressionNode; labels: string[] }
    | { type: 'Label'; name: string }
    | { type: 'Inc'; variable: ExpressionNode }
    | { type: 'Dec'; variable: ExpressionNode }
    | { type: 'Beep'; sound?: ExpressionNode }
    | { type: 'Vsync' }
    | { type: 'Break' }
    | { type: 'Data'; values: ExpressionNode[] }
    | { type: 'Read'; variables: string[] }
    | { type: 'Restore'; label?: string }
    | { type: 'OptionStrict' }
    | { type: 'ExpressionStatement'; expression: ExpressionNode };

export type ExpressionNode =
    | { type: 'Number'; value: number }
    | { type: 'String'; value: string }
    | { type: 'Boolean'; value: boolean }
    | { type: 'Identifier'; name: string }
    | { type: 'ArrayAccess'; array: string; indices: ExpressionNode[] }
    | { type: 'BinaryOp'; op: string; left: ExpressionNode; right: ExpressionNode }
    | { type: 'UnaryOp'; op: string; operand: ExpressionNode }
    | { type: 'FunctionCall'; name: string; args: ExpressionNode[] };

export class Parser {
    private tokens: Token[];
    private pos: number = 0;
    private labels: Map<string, number> = new Map();

    constructor(tokens: Token[]) {
        this.tokens = tokens.filter(t => t.type !== 'NEWLINE' || this.isSignificantNewline(t));
    }

    private isSignificantNewline(_t: Token): boolean {
        return true; // 全ての改行を保持
    }

    parse(): ProgramNode {
        const statements: StatementNode[] = [];
        let stmtIndex = 0;

        while (!this.isAtEnd()) {
            this.skipNewlines();
            if (this.isAtEnd()) break;

            const stmt = this.parseStatement();
            if (stmt) {
                if (stmt.type === 'Label') {
                    this.labels.set(stmt.name, stmtIndex);
                }
                statements.push(stmt);
                stmtIndex++;
            }
        }

        return { type: 'Program', statements, labels: this.labels };
    }

    private parseStatement(): StatementNode | null {
        const token = this.current();

        if (token.type === 'NEWLINE') {
            this.advance();
            return null;
        }

        if (token.type === 'LABEL') {
            this.advance();
            return { type: 'Label', name: token.value };
        }

        if (token.type === 'KEYWORD') {
            const kw = token.value.toUpperCase();

            switch (kw) {
                case 'OPTION':
                    this.advance();
                    if (this.current().value.toUpperCase() === 'STRICT') {
                        this.advance();
                        return { type: 'OptionStrict' };
                    }
                    return null;

                case 'ACLS':
                    this.advance();
                    return { type: 'Acls' };

                case 'PRINT':
                    return this.parsePrint();

                case 'LOCATE':
                    return this.parseLocate();

                case 'COLOR':
                    return this.parseColor();

                case 'GFILL':
                    return this.parseGFill();

                case 'GLINE':
                    return this.parseGLine();

                case 'GBOX':
                    return this.parseGBox();

                case 'GCIRCLE':
                    return this.parseGCircle();

                case 'VAR':
                    return this.parseVar();

                case 'DIM':
                    return this.parseDim();

                case 'CONST':
                    return this.parseConst();

                case 'IF':
                    return this.parseIf();

                case 'FOR':
                    return this.parseFor();

                case 'WHILE':
                    return this.parseWhile();

                case 'LOOP':
                    return this.parseLoop();

                case 'GOSUB':
                    return this.parseGosub();

                case 'RETURN':
                    this.advance();
                    return { type: 'Return' };

                case 'ON':
                    return this.parseOnGosub();

                case 'INC':
                    this.advance();
                    return { type: 'Inc', variable: this.parseExpression() };

                case 'DEC':
                    this.advance();
                    return { type: 'Dec', variable: this.parseExpression() };

                case 'BEEP':
                    this.advance();
                    const sound = this.isExpressionStart() ? this.parseExpression() : undefined;
                    return { type: 'Beep', sound };

                case 'VSYNC':
                    this.advance();
                    return { type: 'Vsync' };

                case 'BREAK':
                    this.advance();
                    return { type: 'Break' };

                case 'DATA':
                    return this.parseData();

                case 'READ':
                    return this.parseRead();

                case 'RESTORE':
                    this.advance();
                    const label = this.current().type === 'LABEL' ? this.advance().value : undefined;
                    return { type: 'Restore', label };

                case 'END':
                case 'ENDIF':
                case 'NEXT':
                case 'WEND':
                case 'ENDLOOP':
                case 'ELSE':
                case 'ELSEIF':
                    // これらは上位の構文で処理
                    return null;
            }
        }

        // 代入文または式
        if (token.type === 'IDENTIFIER') {
            return this.parseAssignmentOrExpression();
        }

        this.advance();
        return null;
    }

    private parsePrint(): StatementNode {
        this.advance(); // PRINT
        const args: ExpressionNode[] = [];
        while (this.isExpressionStart()) {
            args.push(this.parseExpression());
            if (this.check('SEMICOLON') || this.check('COMMA')) {
                this.advance();
            } else {
                break;
            }
        }
        return { type: 'Print', args };
    }

    private parseLocate(): StatementNode {
        this.advance(); // LOCATE
        const x = this.parseExpression();
        this.expect('COMMA');
        const y = this.parseExpression();
        return { type: 'Locate', x, y };
    }

    private parseColor(): StatementNode {
        this.advance(); // COLOR
        const color = this.parseExpression();
        return { type: 'Color', color };
    }

    private parseGFill(): StatementNode {
        this.advance();
        const x1 = this.parseExpression(); this.expect('COMMA');
        const y1 = this.parseExpression(); this.expect('COMMA');
        const x2 = this.parseExpression(); this.expect('COMMA');
        const y2 = this.parseExpression(); this.expect('COMMA');
        const color = this.parseExpression();
        return { type: 'GFill', x1, y1, x2, y2, color };
    }

    private parseGLine(): StatementNode {
        this.advance();
        const x1 = this.parseExpression(); this.expect('COMMA');
        const y1 = this.parseExpression(); this.expect('COMMA');
        const x2 = this.parseExpression(); this.expect('COMMA');
        const y2 = this.parseExpression(); this.expect('COMMA');
        const color = this.parseExpression();
        return { type: 'GLine', x1, y1, x2, y2, color };
    }

    private parseGBox(): StatementNode {
        this.advance();
        const x1 = this.parseExpression(); this.expect('COMMA');
        const y1 = this.parseExpression(); this.expect('COMMA');
        const x2 = this.parseExpression(); this.expect('COMMA');
        const y2 = this.parseExpression(); this.expect('COMMA');
        const color = this.parseExpression();
        return { type: 'GBox', x1, y1, x2, y2, color };
    }

    private parseGCircle(): StatementNode {
        this.advance();
        const x = this.parseExpression(); this.expect('COMMA');
        const y = this.parseExpression(); this.expect('COMMA');
        const r = this.parseExpression(); this.expect('COMMA');
        const color = this.parseExpression();
        let fill: ExpressionNode | undefined;
        if (this.check('COMMA')) {
            this.advance();
            fill = this.parseExpression();
        }
        return { type: 'GCircle', x, y, r, color, fill };
    }

    private parseVar(): StatementNode {
        this.advance(); // VAR
        const name = this.advance().value;
        let value: ExpressionNode | undefined;
        if (this.check('OPERATOR') && this.current().value === '=') {
            this.advance();
            value = this.parseExpression();
        }
        return { type: 'VarDecl', name, value };
    }

    private parseDim(): StatementNode {
        this.advance(); // DIM
        const declarations: { name: string; sizes: ExpressionNode[] }[] = [];

        do {
            const name = this.advance().value;
            const sizes: ExpressionNode[] = [];
            if (this.check('LBRACKET')) {
                this.advance();
                sizes.push(this.parseExpression());
                while (this.check('COMMA')) {
                    this.advance();
                    sizes.push(this.parseExpression());
                }
                this.expect('RBRACKET');
            }
            declarations.push({ name, sizes });
        } while (this.check('COMMA') && (this.advance(), true));

        return { type: 'DimDecl', declarations };
    }

    private parseConst(): StatementNode {
        this.advance(); // CONST
        const name = this.advance().value;
        this.expect('OPERATOR'); // =
        const value = this.parseExpression();
        return { type: 'ConstDecl', name, value };
    }

    private parseIf(): StatementNode {
        this.advance(); // IF
        const condition = this.parseExpression();
        this.expectKeyword('THEN');

        // 単一行IF: THENの後に改行がなく、直接ステートメントが続く場合
        if (!this.check('NEWLINE') && !this.isAtEnd() && !this.checkKeyword('ENDIF')) {
            const stmt = this.parseStatement();
            const thenBlock: StatementNode[] = stmt ? [stmt] : [];
            return { type: 'If', condition, thenBlock };
        }

        this.skipNewlines();

        const thenBlock: StatementNode[] = [];
        let elseBlock: StatementNode[] | undefined;

        while (!this.isAtEnd() && !this.checkKeyword('ENDIF') && !this.checkKeyword('ELSE') && !this.checkKeyword('ELSEIF')) {
            const stmt = this.parseStatement();
            if (stmt) thenBlock.push(stmt);
            this.skipNewlines();
        }

        if (this.checkKeyword('ELSE')) {
            this.advance();
            this.skipNewlines();
            elseBlock = [];
            while (!this.isAtEnd() && !this.checkKeyword('ENDIF')) {
                const stmt = this.parseStatement();
                if (stmt) elseBlock.push(stmt);
                this.skipNewlines();
            }
        } else if (this.checkKeyword('ELSEIF')) {
            elseBlock = [this.parseIf()];
        }

        if (this.checkKeyword('ENDIF')) this.advance();

        return { type: 'If', condition, thenBlock, elseBlock };
    }

    private parseFor(): StatementNode {
        this.advance(); // FOR
        const variable = this.advance().value;
        this.expect('OPERATOR'); // =
        const start = this.parseExpression();
        this.expectKeyword('TO');
        const end = this.parseExpression();
        let step: ExpressionNode | undefined;
        if (this.checkKeyword('STEP')) {
            this.advance();
            step = this.parseExpression();
        }
        this.skipNewlines();

        const body: StatementNode[] = [];
        while (!this.isAtEnd() && !this.checkKeyword('NEXT')) {
            const stmt = this.parseStatement();
            if (stmt) body.push(stmt);
            this.skipNewlines();
        }

        if (this.checkKeyword('NEXT')) this.advance();

        return { type: 'For', variable, start, end, step, body };
    }

    private parseWhile(): StatementNode {
        this.advance(); // WHILE
        const condition = this.parseExpression();
        this.skipNewlines();

        const body: StatementNode[] = [];
        while (!this.isAtEnd() && !this.checkKeyword('WEND')) {
            const stmt = this.parseStatement();
            if (stmt) body.push(stmt);
            this.skipNewlines();
        }

        if (this.checkKeyword('WEND')) this.advance();

        return { type: 'While', condition, body };
    }

    private parseLoop(): StatementNode {
        this.advance(); // LOOP
        this.skipNewlines();

        const body: StatementNode[] = [];
        while (!this.isAtEnd() && !this.checkKeyword('ENDLOOP')) {
            const stmt = this.parseStatement();
            if (stmt) body.push(stmt);
            this.skipNewlines();
        }

        if (this.checkKeyword('ENDLOOP')) this.advance();

        return { type: 'Loop', body };
    }

    private parseGosub(): StatementNode {
        this.advance(); // GOSUB
        const label = this.advance().value;
        return { type: 'Gosub', label };
    }

    private parseOnGosub(): StatementNode {
        this.advance(); // ON
        const index = this.parseExpression();
        this.expectKeyword('GOSUB');
        const labels: string[] = [];
        do {
            labels.push(this.advance().value);
        } while (this.check('COMMA') && (this.advance(), true));
        return { type: 'OnGosub', index, labels };
    }

    private parseData(): StatementNode {
        this.advance(); // DATA
        const values: ExpressionNode[] = [];
        do {
            values.push(this.parseExpression());
        } while (this.check('COMMA') && (this.advance(), true));
        return { type: 'Data', values };
    }

    private parseRead(): StatementNode {
        this.advance(); // READ
        const variables: string[] = [];
        do {
            variables.push(this.advance().value);
        } while (this.check('COMMA') && (this.advance(), true));
        return { type: 'Read', variables };
    }

    private parseAssignmentOrExpression(): StatementNode {
        const expr = this.parseExpression();
        if (this.check('OPERATOR') && this.current().value === '=') {
            this.advance();
            const value = this.parseExpression();
            return { type: 'Assignment', target: expr, value };
        }
        return { type: 'ExpressionStatement', expression: expr };
    }

    private parseExpression(): ExpressionNode {
        return this.parseOr();
    }

    private parseOr(): ExpressionNode {
        let left = this.parseAnd();
        while (this.checkKeyword('OR') || (this.check('OPERATOR') && this.current().value === '||')) {
            this.advance();
            const right = this.parseAnd();
            left = { type: 'BinaryOp', op: '||', left, right };
        }
        return left;
    }

    private parseAnd(): ExpressionNode {
        let left = this.parseComparison();
        while (this.checkKeyword('AND') || (this.check('OPERATOR') && this.current().value === '&&')) {
            this.advance();
            const right = this.parseComparison();
            left = { type: 'BinaryOp', op: '&&', left, right };
        }
        return left;
    }

    private parseComparison(): ExpressionNode {
        let left = this.parseAddition();
        while (this.check('OPERATOR') && ['==', '!=', '<', '>', '<=', '>=', '<>'].includes(this.current().value)) {
            const op = this.advance().value === '<>' ? '!=' : this.tokens[this.pos - 1].value;
            const right = this.parseAddition();
            left = { type: 'BinaryOp', op, left, right };
        }
        return left;
    }

    private parseAddition(): ExpressionNode {
        let left = this.parseMultiplication();
        while (this.check('OPERATOR') && ['+', '-'].includes(this.current().value)) {
            const op = this.advance().value;
            const right = this.parseMultiplication();
            left = { type: 'BinaryOp', op, left, right };
        }
        return left;
    }

    private parseMultiplication(): ExpressionNode {
        let left = this.parseUnary();
        while ((this.check('OPERATOR') && ['*', '/', '%'].includes(this.current().value)) || this.checkKeyword('MOD') || this.checkKeyword('XOR')) {
            const op = this.advance().value.toUpperCase() === 'MOD' ? '%' : this.tokens[this.pos - 1].value;
            const right = this.parseUnary();
            left = { type: 'BinaryOp', op, left, right };
        }
        return left;
    }

    private parseUnary(): ExpressionNode {
        if (this.check('OPERATOR') && ['-', '!'].includes(this.current().value)) {
            const op = this.advance().value;
            const operand = this.parseUnary();
            return { type: 'UnaryOp', op, operand };
        }
        if (this.checkKeyword('NOT')) {
            this.advance();
            const operand = this.parseUnary();
            return { type: 'UnaryOp', op: '!', operand };
        }
        return this.parsePrimary();
    }

    private parsePrimary(): ExpressionNode {
        const token = this.current();

        if (token.type === 'NUMBER') {
            this.advance();
            const val = token.value;
            if (val.startsWith('#')) {
                // 16進数カラー
                return { type: 'Number', value: parseInt(val.slice(1), 16) };
            }
            return { type: 'Number', value: parseFloat(val) };
        }

        if (token.type === 'STRING') {
            this.advance();
            return { type: 'String', value: token.value };
        }

        if (token.type === 'KEYWORD') {
            const kw = token.value.toUpperCase();
            if (kw === 'TRUE') {
                this.advance();
                return { type: 'Boolean', value: true };
            }
            if (kw === 'FALSE') {
                this.advance();
                return { type: 'Boolean', value: false };
            }
            if (kw === 'PI') {
                this.advance();
                return { type: 'Number', value: Math.PI };
            }
            // 組み込み関数
            return this.parseFunctionCall();
        }

        if (token.type === 'IDENTIFIER') {
            this.advance();
            const name = token.value;
            // 配列アクセス
            if (this.check('LBRACKET')) {
                this.advance();
                const indices: ExpressionNode[] = [this.parseExpression()];
                while (this.check('COMMA')) {
                    this.advance();
                    indices.push(this.parseExpression());
                }
                this.expect('RBRACKET');
                return { type: 'ArrayAccess', array: name, indices };
            }
            // 関数呼び出し
            if (this.check('LPAREN')) {
                this.advance();
                const args: ExpressionNode[] = [];
                if (!this.check('RPAREN')) {
                    args.push(this.parseExpression());
                    while (this.check('COMMA')) {
                        this.advance();
                        args.push(this.parseExpression());
                    }
                }
                this.expect('RPAREN');
                return { type: 'FunctionCall', name, args };
            }
            return { type: 'Identifier', name };
        }

        if (this.check('LPAREN')) {
            this.advance();
            const expr = this.parseExpression();
            this.expect('RPAREN');
            return expr;
        }

        throw new Error(`Unexpected token: ${token.type} ${token.value} at line ${token.line}`);
    }

    private parseFunctionCall(): ExpressionNode {
        const name = this.advance().value;
        if (this.check('LPAREN')) {
            this.advance();
            const args: ExpressionNode[] = [];
            if (!this.check('RPAREN')) {
                args.push(this.parseExpression());
                while (this.check('COMMA')) {
                    this.advance();
                    args.push(this.parseExpression());
                }
            }
            this.expect('RPAREN');
            return { type: 'FunctionCall', name, args };
        }
        // 引数なし関数
        return { type: 'FunctionCall', name, args: [] };
    }

    private skipNewlines() {
        while (this.check('NEWLINE')) {
            this.advance();
        }
    }

    private isExpressionStart(): boolean {
        const t = this.current();
        return t.type === 'NUMBER' || t.type === 'STRING' || t.type === 'IDENTIFIER' ||
            t.type === 'LPAREN' || t.type === 'KEYWORD' ||
            (t.type === 'OPERATOR' && ['-', '!'].includes(t.value));
    }

    private current(): Token {
        return this.tokens[this.pos] || { type: 'EOF', value: '', line: 0, column: 0 };
    }

    private advance(): Token {
        return this.tokens[this.pos++];
    }

    private check(type: TokenType): boolean {
        return this.current().type === type;
    }

    private checkKeyword(kw: string): boolean {
        return this.current().type === 'KEYWORD' && this.current().value.toUpperCase() === kw;
    }

    private expect(type: TokenType): Token {
        if (!this.check(type)) {
            throw new Error(`Expected ${type} but got ${this.current().type} at line ${this.current().line}`);
        }
        return this.advance();
    }

    private expectKeyword(kw: string): Token {
        if (!this.checkKeyword(kw)) {
            throw new Error(`Expected ${kw} but got ${this.current().value} at line ${this.current().line}`);
        }
        return this.advance();
    }

    private isAtEnd(): boolean {
        return this.current().type === 'EOF';
    }
}
