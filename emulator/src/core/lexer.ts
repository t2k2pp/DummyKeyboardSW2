// SmileBASIC Lexer - 字句解析
export type TokenType =
    | 'NUMBER' | 'STRING' | 'IDENTIFIER' | 'LABEL'
    | 'KEYWORD' | 'OPERATOR' | 'LPAREN' | 'RPAREN'
    | 'LBRACKET' | 'RBRACKET' | 'COMMA' | 'COLON' | 'SEMICOLON'
    | 'NEWLINE' | 'EOF' | 'COMMENT';

export interface Token {
    type: TokenType;
    value: string;
    line: number;
    column: number;
}

const KEYWORDS = new Set([
    'ACLS', 'PRINT', 'LOCATE', 'COLOR', 'CLS',
    'GFILL', 'GLINE', 'GBOX', 'GCIRCLE', 'GTRI', 'GPSET',
    'DIM', 'VAR', 'CONST', 'LET',
    'IF', 'THEN', 'ELSE', 'ELSEIF', 'ENDIF',
    'FOR', 'TO', 'STEP', 'NEXT',
    'WHILE', 'WEND',
    'LOOP', 'ENDLOOP',
    'GOSUB', 'RETURN', 'GOTO',
    'ON', 'END',
    'AND', 'OR', 'NOT', 'MOD', 'XOR',
    'TRUE', 'FALSE',
    'OPTION', 'STRICT',
    'DATA', 'READ', 'RESTORE',
    'RND', 'ABS', 'MIN', 'MAX', 'INT', 'FLOOR', 'CEIL', 'SIN', 'COS', 'PI',
    'LEN', 'LEFT$', 'RIGHT$', 'MID$', 'INSTR', 'STR$', 'VAL', 'CHR$', 'ASC', 'FORMAT$',
    'BUTTON', 'INKEY$',
    'VSYNC', 'BEEP',
    'INC', 'DEC', 'BREAK',
    'RGB'
]);

const OPERATORS = [
    '==', '!=', '<=', '>=', '<>', '<', '>',
    '&&', '||', '!',
    '+=', '-=', '*=', '/=',
    '+', '-', '*', '/', '%',
    '='
];

export class Lexer {
    private code: string;
    private pos: number = 0;
    private line: number = 1;
    private column: number = 1;

    constructor(code: string) {
        this.code = code;
    }

    tokenize(): Token[] {
        const tokens: Token[] = [];
        while (this.pos < this.code.length) {
            const token = this.nextToken();
            if (token) {
                tokens.push(token);
            }
        }
        tokens.push({ type: 'EOF', value: '', line: this.line, column: this.column });
        return tokens;
    }

    private nextToken(): Token | null {
        this.skipWhitespace();
        if (this.pos >= this.code.length) return null;

        const ch = this.code[this.pos];
        const startLine = this.line;
        const startColumn = this.column;

        // コメント
        if (ch === "'") {
            const start = this.pos;
            while (this.pos < this.code.length && this.code[this.pos] !== '\n') {
                this.advance();
            }
            return null; // コメントはスキップ
        }

        // 改行
        if (ch === '\n' || ch === '\r') {
            if (ch === '\r' && this.code[this.pos + 1] === '\n') {
                this.advance();
            }
            this.advance();
            this.line++;
            this.column = 1;
            return { type: 'NEWLINE', value: '\n', line: startLine, column: startColumn };
        }

        // 文字列
        if (ch === '"') {
            return this.readString();
        }

        // 数値
        if (this.isDigit(ch) || (ch === '.' && this.isDigit(this.code[this.pos + 1]))) {
            return this.readNumber();
        }

        // 16進数
        if (ch === '#') {
            return this.readHexColor();
        }

        // 2進数
        if (ch === '%' && (this.code[this.pos + 1] === '0' || this.code[this.pos + 1] === '1')) {
            return this.readBinary();
        }

        // ラベル
        if (ch === '@') {
            return this.readLabel();
        }

        // 識別子またはキーワード
        if (this.isAlpha(ch) || ch === '_') {
            return this.readIdentifier();
        }

        // 括弧類
        if (ch === '(') { this.advance(); return { type: 'LPAREN', value: '(', line: startLine, column: startColumn }; }
        if (ch === ')') { this.advance(); return { type: 'RPAREN', value: ')', line: startLine, column: startColumn }; }
        if (ch === '[') { this.advance(); return { type: 'LBRACKET', value: '[', line: startLine, column: startColumn }; }
        if (ch === ']') { this.advance(); return { type: 'RBRACKET', value: ']', line: startLine, column: startColumn }; }
        if (ch === ',') { this.advance(); return { type: 'COMMA', value: ',', line: startLine, column: startColumn }; }
        if (ch === ':') { this.advance(); return { type: 'COLON', value: ':', line: startLine, column: startColumn }; }
        if (ch === ';') { this.advance(); return { type: 'SEMICOLON', value: ';', line: startLine, column: startColumn }; }

        // 演算子
        for (const op of OPERATORS) {
            if (this.code.substr(this.pos, op.length) === op) {
                for (let i = 0; i < op.length; i++) this.advance();
                return { type: 'OPERATOR', value: op, line: startLine, column: startColumn };
            }
        }

        // 不明な文字はスキップ
        this.advance();
        return null;
    }

    private readString(): Token {
        const startLine = this.line;
        const startColumn = this.column;
        this.advance(); // 開始の"
        let value = '';
        while (this.pos < this.code.length && this.code[this.pos] !== '"' && this.code[this.pos] !== '\n') {
            value += this.code[this.pos];
            this.advance();
        }
        if (this.code[this.pos] === '"') this.advance();
        return { type: 'STRING', value, line: startLine, column: startColumn };
    }

    private readNumber(): Token {
        const startLine = this.line;
        const startColumn = this.column;
        let value = '';
        let hasDot = false;
        while (this.pos < this.code.length) {
            const ch = this.code[this.pos];
            if (this.isDigit(ch)) {
                value += ch;
                this.advance();
            } else if (ch === '.' && !hasDot) {
                hasDot = true;
                value += ch;
                this.advance();
            } else if (ch === '!' || ch === '#') {
                // 型接尾辞
                this.advance();
                break;
            } else {
                break;
            }
        }
        return { type: 'NUMBER', value, line: startLine, column: startColumn };
    }

    private readHexColor(): Token {
        const startLine = this.line;
        const startColumn = this.column;
        this.advance(); // #
        let value = '#';
        while (this.pos < this.code.length && /[0-9A-Fa-f]/.test(this.code[this.pos])) {
            value += this.code[this.pos];
            this.advance();
        }
        return { type: 'NUMBER', value, line: startLine, column: startColumn };
    }

    private readBinary(): Token {
        const startLine = this.line;
        const startColumn = this.column;
        this.advance(); // %
        let value = '';
        while (this.pos < this.code.length && (this.code[this.pos] === '0' || this.code[this.pos] === '1')) {
            value += this.code[this.pos];
            this.advance();
        }
        // 2進数を10進数に変換
        const decimal = parseInt(value, 2);
        return { type: 'NUMBER', value: decimal.toString(), line: startLine, column: startColumn };
    }

    private readLabel(): Token {
        const startLine = this.line;
        const startColumn = this.column;
        this.advance(); // @
        let value = '@';
        while (this.pos < this.code.length && (this.isAlphaNumeric(this.code[this.pos]) || this.code[this.pos] === '_')) {
            value += this.code[this.pos];
            this.advance();
        }
        return { type: 'LABEL', value, line: startLine, column: startColumn };
    }

    private readIdentifier(): Token {
        const startLine = this.line;
        const startColumn = this.column;
        let value = '';
        while (this.pos < this.code.length && (this.isAlphaNumeric(this.code[this.pos]) || this.code[this.pos] === '_' || this.code[this.pos] === '$' || this.code[this.pos] === '!' || this.code[this.pos] === '#')) {
            value += this.code[this.pos];
            this.advance();
        }
        const upper = value.toUpperCase().replace(/[$!#]$/, '');
        const type: TokenType = KEYWORDS.has(upper) ? 'KEYWORD' : 'IDENTIFIER';
        return { type, value, line: startLine, column: startColumn };
    }

    private skipWhitespace() {
        while (this.pos < this.code.length && (this.code[this.pos] === ' ' || this.code[this.pos] === '\t')) {
            this.advance();
        }
    }

    private advance() {
        this.pos++;
        this.column++;
    }

    private isDigit(ch: string): boolean {
        return ch >= '0' && ch <= '9';
    }

    private isAlpha(ch: string): boolean {
        return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
    }

    private isAlphaNumeric(ch: string): boolean {
        return this.isAlpha(ch) || this.isDigit(ch);
    }
}
