// SmileBASIC Parser - 構文解析器
import type { Token, TokenType, Program, Statement, Expression, LValue } from './ast';

export class Parser {
    private tokens: Token[] = [];
    private pos = 0;

    parse(tokens: Token[]): Program {
        this.tokens = tokens;
        this.pos = 0;
        const body: Statement[] = [];

        while (!this.isAtEnd()) {
            this.skipNewlines();
            if (this.isAtEnd()) break;

            const stmts = this.parseLineStatements();
            body.push(...stmts);
        }

        return { type: 'Program', body };
    }

    // 1行分の文を解析（コロン区切り対応）
    private parseLineStatements(): Statement[] {
        const stmts: Statement[] = [];

        while (!this.isAtEnd() && !this.check('NEWLINE')) {
            const stmt = this.parseStatement();
            if (stmt) stmts.push(stmt);

            // コロン区切りがあれば次の文へ
            if (this.check('COLON')) {
                this.advance();
            } else {
                break;
            }
        }

        // 改行を消費
        if (this.check('NEWLINE')) this.advance();

        return stmts;
    }

    private parseStatement(): Statement | null {
        const token = this.current();

        // ラベル
        if (token.type === 'LABEL') {
            this.advance();
            return { type: 'Label', name: token.value, line: token.line };
        }

        // キーワード
        if (token.type === 'KEYWORD') {
            const kw = token.value.toUpperCase();

            switch (kw) {
                case 'OPTION':
                    this.advance();
                    if (this.matchKeyword('STRICT')) this.advance();
                    return null;

                case 'ACLS': this.advance(); return { type: 'Acls' };
                case 'VSYNC': this.advance(); return { type: 'Vsync' };
                case 'BREAK': this.advance(); return { type: 'Break' };
                case 'RETURN':
                    this.advance();
                    const retVal = this.isExpressionStart() ? this.parseExpression() : undefined;
                    return { type: 'Return', value: retVal };

                case 'PRINT': return this.parsePrint();
                case 'LOCATE': return this.parseLocate();
                case 'COLOR': return this.parseColor();
                case 'GFILL': return this.parseGfill();
                case 'GLINE': return this.parseGline();
                case 'GBOX': return this.parseGbox();
                case 'GCIRCLE': return this.parseGcircle();
                case 'VAR': return this.parseVar();
                case 'DIM': return this.parseDim();
                case 'CONST': return this.parseConst();
                case 'IF': return this.parseIf();
                case 'FOR': return this.parseFor();
                case 'WHILE': return this.parseWhile();
                case 'LOOP': return this.parseLoop();
                case 'GOSUB': return this.parseGosub();
                case 'ON': return this.parseOn();
                case 'INC': this.advance(); return { type: 'Inc', target: this.parseLValue() };
                case 'DEC': this.advance(); return { type: 'Dec', target: this.parseLValue() };
                case 'BEEP':
                    this.advance();
                    return { type: 'Beep', sound: this.isExpressionStart() ? this.parseExpression() : undefined };
                case 'DATA': return this.parseData();
                case 'READ': return this.parseRead();
                case 'RESTORE':
                    this.advance();
                    const label = this.check('LABEL') ? this.advance().value : undefined;
                    return { type: 'Restore', label };

                // ブロック終端キーワード（上位で処理）
                case 'ENDIF': case 'ELSE': case 'ELSEIF':
                case 'NEXT': case 'WEND': case 'ENDLOOP':
                case 'END':
                    return null;
            }
        }

        // 識別子から始まる場合（代入または式）
        if (token.type === 'IDENTIFIER') {
            return this.parseAssignmentOrExpr();
        }

        // 不明なトークンはスキップ
        this.advance();
        return null;
    }

    // ===== 各文のパース =====

    private parsePrint(): Statement {
        this.advance(); // PRINT
        const args: Expression[] = [];
        let newline = true;

        while (this.isExpressionStart()) {
            args.push(this.parseExpression());
            if (this.check('SEMICOLON')) {
                this.advance();
                newline = false;
            } else if (this.check('COMMA')) {
                this.advance();
            } else {
                break;
            }
        }
        return { type: 'Print', args, newline };
    }

    private parseLocate(): Statement {
        this.advance(); // LOCATE
        const x = this.parseExpression();
        this.expect('COMMA');
        const y = this.parseExpression();
        return { type: 'Locate', x, y };
    }

    private parseColor(): Statement {
        this.advance(); // COLOR
        const color = this.parseExpression();
        return { type: 'Color', color };
    }

    private parseGfill(): Statement {
        this.advance();
        const x1 = this.parseExpression(); this.expect('COMMA');
        const y1 = this.parseExpression(); this.expect('COMMA');
        const x2 = this.parseExpression(); this.expect('COMMA');
        const y2 = this.parseExpression(); this.expect('COMMA');
        const color = this.parseExpression();
        return { type: 'Gfill', x1, y1, x2, y2, color };
    }

    private parseGline(): Statement {
        this.advance();
        const x1 = this.parseExpression(); this.expect('COMMA');
        const y1 = this.parseExpression(); this.expect('COMMA');
        const x2 = this.parseExpression(); this.expect('COMMA');
        const y2 = this.parseExpression(); this.expect('COMMA');
        const color = this.parseExpression();
        return { type: 'Gline', x1, y1, x2, y2, color };
    }

    private parseGbox(): Statement {
        this.advance();
        const x1 = this.parseExpression(); this.expect('COMMA');
        const y1 = this.parseExpression(); this.expect('COMMA');
        const x2 = this.parseExpression(); this.expect('COMMA');
        const y2 = this.parseExpression(); this.expect('COMMA');
        const color = this.parseExpression();
        return { type: 'Gbox', x1, y1, x2, y2, color };
    }

    private parseGcircle(): Statement {
        this.advance();
        const x = this.parseExpression(); this.expect('COMMA');
        const y = this.parseExpression(); this.expect('COMMA');
        const r = this.parseExpression(); this.expect('COMMA');
        const color = this.parseExpression();
        let fill: Expression | undefined;
        if (this.check('COMMA')) {
            this.advance();
            fill = this.parseExpression();
        }
        return { type: 'Gcircle', x, y, r, color, fill };
    }

    private parseVar(): Statement {
        this.advance(); // VAR
        const name = this.advance().value;
        let value: Expression | undefined;
        if (this.checkOp('=')) {
            this.advance();
            value = this.parseExpression();
        }
        return { type: 'VarDecl', name, value };
    }

    private parseDim(): Statement {
        this.advance(); // DIM
        const declarations: { name: string; sizes: Expression[] }[] = [];

        do {
            const name = this.advance().value;
            const sizes: Expression[] = [];

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
        } while (this.check('COMMA') && !this.isNextBracket() && (this.advance(), true));

        return { type: 'DimDecl', declarations };
    }

    private isNextBracket(): boolean {
        // 次のトークンがCOMMAの後にLBRACKETが来るかチェック
        // DIM A[10], B[20] のような場合に対応
        const nextPos = this.pos + 1;
        return this.tokens[nextPos]?.type === 'LBRACKET';
    }

    private parseConst(): Statement {
        this.advance(); // CONST
        const name = this.advance().value;
        this.expectOp('=');
        const value = this.parseExpression();
        return { type: 'ConstDecl', name, value };
    }

    private parseIf(): Statement {
        this.advance(); // IF
        const condition = this.parseExpression();
        this.expectKeyword('THEN');

        // 単一行IF: THENの後に改行がなくステートメントが続く場合
        if (!this.check('NEWLINE') && !this.isAtEnd() && !this.checkKeyword('ENDIF')) {
            const thenStmts = this.parseLineStatements();
            return { type: 'If', condition, thenBody: thenStmts };
        }

        this.skipNewlines();

        const thenBody: Statement[] = [];
        let elseBody: Statement[] | undefined;

        // THEN ブロック
        while (!this.isAtEnd() && !this.checkKeyword('ENDIF') && !this.checkKeyword('ELSE') && !this.checkKeyword('ELSEIF')) {
            const stmts = this.parseLineStatements();
            thenBody.push(...stmts);
        }

        // ELSE / ELSEIF
        if (this.checkKeyword('ELSEIF')) {
            elseBody = [this.parseIf()];
        } else if (this.checkKeyword('ELSE')) {
            this.advance();
            this.skipNewlines();
            elseBody = [];
            while (!this.isAtEnd() && !this.checkKeyword('ENDIF')) {
                const stmts = this.parseLineStatements();
                elseBody.push(...stmts);
            }
        }

        if (this.checkKeyword('ENDIF')) this.advance();

        return { type: 'If', condition, thenBody, elseBody };
    }

    private parseFor(): Statement {
        this.advance(); // FOR
        const variable = this.advance().value;
        this.expectOp('=');
        const start = this.parseExpression();
        this.expectKeyword('TO');
        const end = this.parseExpression();
        let step: Expression | undefined;
        if (this.checkKeyword('STEP')) {
            this.advance();
            step = this.parseExpression();
        }
        this.skipNewlines();

        const body: Statement[] = [];
        while (!this.isAtEnd() && !this.checkKeyword('NEXT')) {
            const stmts = this.parseLineStatements();
            body.push(...stmts);
        }
        if (this.checkKeyword('NEXT')) this.advance();

        return { type: 'For', variable, start, end, step, body };
    }

    private parseWhile(): Statement {
        this.advance(); // WHILE
        const condition = this.parseExpression();
        this.skipNewlines();

        const body: Statement[] = [];
        while (!this.isAtEnd() && !this.checkKeyword('WEND')) {
            const stmts = this.parseLineStatements();
            body.push(...stmts);
        }
        if (this.checkKeyword('WEND')) this.advance();

        return { type: 'While', condition, body };
    }

    private parseLoop(): Statement {
        this.advance(); // LOOP
        this.skipNewlines();

        const body: Statement[] = [];
        while (!this.isAtEnd() && !this.checkKeyword('ENDLOOP')) {
            const stmts = this.parseLineStatements();
            body.push(...stmts);
        }
        if (this.checkKeyword('ENDLOOP')) this.advance();

        return { type: 'Loop', body };
    }

    private parseGosub(): Statement {
        this.advance(); // GOSUB
        const label = this.advance().value;
        return { type: 'Gosub', label };
    }

    private parseOn(): Statement {
        this.advance(); // ON
        const index = this.parseExpression();
        this.expectKeyword('GOSUB');
        const labels: string[] = [];
        do {
            labels.push(this.advance().value);
        } while (this.check('COMMA') && (this.advance(), true));
        return { type: 'OnGosub', index, labels };
    }

    private parseData(): Statement {
        const line = this.current().line;
        this.advance(); // DATA
        const values: Expression[] = [];
        do {
            values.push(this.parseExpression());
        } while (this.check('COMMA') && (this.advance(), true));
        return { type: 'Data', values, line };
    }

    private parseRead(): Statement {
        this.advance(); // READ
        const variables: string[] = [];
        do {
            variables.push(this.advance().value);
        } while (this.check('COMMA') && (this.advance(), true));
        return { type: 'Read', variables };
    }

    private parseAssignmentOrExpr(): Statement {
        const lvalue = this.parseLValue();
        if (this.checkOp('=')) {
            this.advance();
            const value = this.parseExpression();
            return { type: 'Assignment', target: lvalue, value };
        }
        // 配列アクセスの場合は式として再構築
        if (lvalue.type === 'ArrayAccess') {
            return { type: 'ExpressionStmt', expression: { type: 'ArrayAccess', name: lvalue.name, indices: lvalue.indices } };
        }
        return { type: 'ExpressionStmt', expression: { type: 'Identifier', name: lvalue.name } };
    }

    private parseLValue(): LValue {
        const name = this.advance().value;
        if (this.check('LBRACKET')) {
            this.advance();
            const indices: Expression[] = [this.parseExpression()];
            while (this.check('COMMA')) {
                this.advance();
                indices.push(this.parseExpression());
            }
            this.expect('RBRACKET');
            return { type: 'ArrayAccess', name, indices };
        }
        return { type: 'Identifier', name };
    }

    // ===== 式のパース =====

    private parseExpression(): Expression {
        return this.parseOr();
    }

    private parseOr(): Expression {
        let left = this.parseAnd();
        while (this.checkKeyword('OR') || this.checkOp('||')) {
            this.advance();
            left = { type: 'Binary', op: '||', left, right: this.parseAnd() };
        }
        return left;
    }

    private parseAnd(): Expression {
        let left = this.parseComparison();
        while (this.checkKeyword('AND') || this.checkOp('&&')) {
            this.advance();
            left = { type: 'Binary', op: '&&', left, right: this.parseComparison() };
        }
        return left;
    }

    private parseComparison(): Expression {
        let left = this.parseAddition();
        while (this.check('OPERATOR') && ['==', '!=', '<', '>', '<=', '>='].includes(this.current().value)) {
            const op = this.advance().value;
            left = { type: 'Binary', op, left, right: this.parseAddition() };
        }
        return left;
    }

    private parseAddition(): Expression {
        let left = this.parseMultiplication();
        while (this.check('OPERATOR') && ['+', '-'].includes(this.current().value)) {
            const op = this.advance().value;
            left = { type: 'Binary', op, left, right: this.parseMultiplication() };
        }
        return left;
    }

    private parseMultiplication(): Expression {
        let left = this.parseUnary();
        while ((this.check('OPERATOR') && ['*', '/', '%'].includes(this.current().value)) ||
            this.checkKeyword('MOD') || this.checkKeyword('XOR')) {
            const op = this.advance().value.toUpperCase() === 'MOD' ? '%' : this.tokens[this.pos - 1].value;
            left = { type: 'Binary', op, left, right: this.parseUnary() };
        }
        return left;
    }

    private parseUnary(): Expression {
        if (this.check('OPERATOR') && ['-', '!'].includes(this.current().value)) {
            const op = this.advance().value;
            return { type: 'Unary', op, operand: this.parseUnary() };
        }
        if (this.checkKeyword('NOT')) {
            this.advance();
            return { type: 'Unary', op: '!', operand: this.parseUnary() };
        }
        // GOSUB式（IF GOSUB(@LABEL) THEN...）
        if (this.checkKeyword('GOSUB')) {
            this.advance();
            const label = this.advance().value;
            return { type: 'GosubExpr', label };
        }
        return this.parsePrimary();
    }

    private parsePrimary(): Expression {
        const token = this.current();

        // 数値
        if (token.type === 'NUMBER') {
            this.advance();
            if (token.value.startsWith('#')) {
                return { type: 'Number', value: parseInt(token.value.slice(1), 16) };
            }
            return { type: 'Number', value: parseFloat(token.value) };
        }

        // 文字列
        if (token.type === 'STRING') {
            this.advance();
            return { type: 'String', value: token.value };
        }

        // TRUE/FALSE
        if (token.type === 'KEYWORD') {
            const kw = token.value.toUpperCase();
            if (kw === 'TRUE') { this.advance(); return { type: 'Boolean', value: true }; }
            if (kw === 'FALSE') { this.advance(); return { type: 'Boolean', value: false }; }
            if (kw === 'PI') { this.advance(); return { type: 'Number', value: Math.PI }; }
            // 組み込み関数
            return this.parseCall();
        }

        // 識別子（変数または配列）
        if (token.type === 'IDENTIFIER') {
            this.advance();
            const name = token.value;
            // 関数呼び出し
            if (this.check('LPAREN')) {
                this.advance();
                const args: Expression[] = [];
                if (!this.check('RPAREN')) {
                    args.push(this.parseExpression());
                    while (this.check('COMMA')) {
                        this.advance();
                        args.push(this.parseExpression());
                    }
                }
                this.expect('RPAREN');
                return { type: 'Call', name, args };
            }
            // 配列アクセス
            if (this.check('LBRACKET')) {
                this.advance();
                const indices: Expression[] = [this.parseExpression()];
                while (this.check('COMMA')) {
                    this.advance();
                    indices.push(this.parseExpression());
                }
                this.expect('RBRACKET');
                return { type: 'ArrayAccess', name, indices };
            }
            return { type: 'Identifier', name };
        }

        // 括弧
        if (this.check('LPAREN')) {
            this.advance();
            const expr = this.parseExpression();
            this.expect('RPAREN');
            return expr;
        }

        throw new Error(`Unexpected token: ${token.type} "${token.value}" at line ${token.line}`);
    }

    private parseCall(): Expression {
        const name = this.advance().value;
        if (this.check('LPAREN')) {
            this.advance();
            const args: Expression[] = [];
            if (!this.check('RPAREN')) {
                args.push(this.parseExpression());
                while (this.check('COMMA')) {
                    this.advance();
                    args.push(this.parseExpression());
                }
            }
            this.expect('RPAREN');
            return { type: 'Call', name, args };
        }
        // 引数なし関数呼び出し
        return { type: 'Call', name, args: [] };
    }

    // ===== ヘルパー =====

    private skipNewlines() {
        while (this.check('NEWLINE')) this.advance();
    }

    private isExpressionStart(): boolean {
        const t = this.current();
        return t.type === 'NUMBER' || t.type === 'STRING' ||
            t.type === 'IDENTIFIER' || t.type === 'LPAREN' ||
            t.type === 'KEYWORD' ||
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

    private matchKeyword(kw: string): boolean {
        return this.checkKeyword(kw);
    }

    private checkOp(op: string): boolean {
        return this.current().type === 'OPERATOR' && this.current().value === op;
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

    private expectOp(op: string): Token {
        if (!this.checkOp(op)) {
            throw new Error(`Expected operator ${op} but got ${this.current().value} at line ${this.current().line}`);
        }
        return this.advance();
    }

    private isAtEnd(): boolean {
        return this.current().type === 'EOF';
    }
}
