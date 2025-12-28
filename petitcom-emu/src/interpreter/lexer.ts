// SmileBASIC Lexer - 字句解析器
import type { Token, TokenType } from './ast';

const KEYWORDS = new Set([
    'OPTION', 'STRICT', 'ACLS', 'PRINT', 'LOCATE', 'COLOR',
    'GFILL', 'GLINE', 'GBOX', 'GCIRCLE', 'GPOINT',
    'VAR', 'DIM', 'CONST', 'TRUE', 'FALSE',
    'IF', 'THEN', 'ELSE', 'ELSEIF', 'ENDIF',
    'FOR', 'TO', 'STEP', 'NEXT',
    'WHILE', 'WEND', 'LOOP', 'ENDLOOP',
    'GOSUB', 'RETURN', 'ON', 'GOTO',
    'INC', 'DEC', 'BREAK', 'CONTINUE',
    'BEEP', 'VSYNC',
    'DATA', 'READ', 'RESTORE',
    'AND', 'OR', 'NOT', 'XOR', 'MOD',
    'RND', 'ABS', 'MIN', 'MAX', 'INT', 'FLOOR', 'CEIL', 'SIN', 'COS', 'TAN', 'ATAN', 'SQRT', 'PI',
    'LEN', 'LEFT$', 'RIGHT$', 'MID$', 'INSTR', 'STR$', 'VAL', 'CHR$', 'ASC', 'FORMAT$',
    'BUTTON', 'INKEY$', 'RGB', 'TIME$', 'DATE$',
    'END'
]);

export class Lexer {
    private source: string;
    private pos = 0;
    private line = 1;
    private column = 1;
    private tokens: Token[] = [];

    constructor(source: string) {
        // Windows改行をUnix改行に正規化
        this.source = source.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    }

    tokenize(): Token[] {
        while (!this.isAtEnd()) {
            this.scanToken();
        }
        this.addToken('EOF', '');
        return this.tokens;
    }

    private scanToken() {
        const ch = this.peek();

        // 空白（改行以外）
        if (ch === ' ' || ch === '\t') {
            this.advance();
            return;
        }

        // 改行
        if (ch === '\n') {
            this.addToken('NEWLINE', '\\n');
            this.advance();
            this.line++;
            this.column = 1;
            return;
        }

        // コメント
        if (ch === "'") {
            while (!this.isAtEnd() && this.peek() !== '\n') {
                this.advance();
            }
            return;
        }

        // 文字列
        if (ch === '"') {
            this.scanString();
            return;
        }

        // 数値（16進数カラーコード含む）
        if (ch === '#' && this.isHexDigit(this.peekNext())) {
            this.scanHexNumber();
            return;
        }

        if (this.isDigit(ch)) {
            this.scanNumber();
            return;
        }

        // 識別子・キーワード・ラベル
        if (ch === '@') {
            this.scanLabel();
            return;
        }

        if (this.isAlpha(ch)) {
            this.scanIdentifier();
            return;
        }

        // 演算子・記号
        switch (ch) {
            case '(': this.addToken('LPAREN', '('); this.advance(); return;
            case ')': this.addToken('RPAREN', ')'); this.advance(); return;
            case '[': this.addToken('LBRACKET', '['); this.advance(); return;
            case ']': this.addToken('RBRACKET', ']'); this.advance(); return;
            case ',': this.addToken('COMMA', ','); this.advance(); return;
            case ';': this.addToken('SEMICOLON', ';'); this.advance(); return;
            case ':': this.addToken('COLON', ':'); this.advance(); return;
            case '+': this.addToken('OPERATOR', '+'); this.advance(); return;
            case '-': this.addToken('OPERATOR', '-'); this.advance(); return;
            case '*': this.addToken('OPERATOR', '*'); this.advance(); return;
            case '/': this.addToken('OPERATOR', '/'); this.advance(); return;
            case '%': this.addToken('OPERATOR', '%'); this.advance(); return;
            case '=':
                if (this.peekNext() === '=') {
                    this.addToken('OPERATOR', '==');
                    this.advance(); this.advance();
                } else {
                    this.addToken('OPERATOR', '=');
                    this.advance();
                }
                return;
            case '!':
                if (this.peekNext() === '=') {
                    this.addToken('OPERATOR', '!=');
                    this.advance(); this.advance();
                } else {
                    this.addToken('OPERATOR', '!');
                    this.advance();
                }
                return;
            case '<':
                if (this.peekNext() === '=') {
                    this.addToken('OPERATOR', '<=');
                    this.advance(); this.advance();
                } else if (this.peekNext() === '>') {
                    this.addToken('OPERATOR', '!=');
                    this.advance(); this.advance();
                } else {
                    this.addToken('OPERATOR', '<');
                    this.advance();
                }
                return;
            case '>':
                if (this.peekNext() === '=') {
                    this.addToken('OPERATOR', '>=');
                    this.advance(); this.advance();
                } else {
                    this.addToken('OPERATOR', '>');
                    this.advance();
                }
                return;
            case '&':
                if (this.peekNext() === '&') {
                    this.addToken('OPERATOR', '&&');
                    this.advance(); this.advance();
                } else {
                    this.addToken('OPERATOR', '&');
                    this.advance();
                }
                return;
            case '|':
                if (this.peekNext() === '|') {
                    this.addToken('OPERATOR', '||');
                    this.advance(); this.advance();
                } else {
                    this.addToken('OPERATOR', '|');
                    this.advance();
                }
                return;
        }

        // 不明な文字はスキップ
        this.advance();
    }

    private scanString() {
        this.advance(); // 開始の"
        let value = '';
        while (!this.isAtEnd() && this.peek() !== '"') {
            if (this.peek() === '\n') {
                this.line++;
                this.column = 0;
            }
            value += this.advance();
        }
        if (!this.isAtEnd()) this.advance(); // 終了の"
        this.addToken('STRING', value);
    }

    private scanNumber() {
        let value = '';
        while (this.isDigit(this.peek())) {
            value += this.advance();
        }
        if (this.peek() === '.' && this.isDigit(this.peekNext())) {
            value += this.advance(); // .
            while (this.isDigit(this.peek())) {
                value += this.advance();
            }
        }
        this.addToken('NUMBER', value);
    }

    private scanHexNumber() {
        let value = '#';
        this.advance(); // #
        while (this.isHexDigit(this.peek())) {
            value += this.advance();
        }
        this.addToken('NUMBER', value);
    }

    private scanLabel() {
        let value = '@';
        this.advance(); // @
        while (this.isAlphaNumeric(this.peek()) || this.peek() === '_') {
            value += this.advance();
        }
        this.addToken('LABEL', value);
    }

    private scanIdentifier() {
        let value = '';
        while (this.isAlphaNumeric(this.peek()) || this.peek() === '_' || this.peek() === '$' || this.peek() === '!' || this.peek() === '#') {
            value += this.advance();
        }
        const upper = value.toUpperCase().replace(/[$!#]$/, '');
        if (KEYWORDS.has(upper)) {
            this.addToken('KEYWORD', value);
        } else {
            this.addToken('IDENTIFIER', value);
        }
    }

    private addToken(type: TokenType, value: string) {
        this.tokens.push({ type, value, line: this.line, column: this.column });
    }

    private peek(): string {
        return this.source[this.pos] || '\0';
    }

    private peekNext(): string {
        return this.source[this.pos + 1] || '\0';
    }

    private advance(): string {
        const ch = this.source[this.pos++];
        this.column++;
        return ch;
    }

    private isAtEnd(): boolean {
        return this.pos >= this.source.length;
    }

    private isDigit(ch: string): boolean {
        return ch >= '0' && ch <= '9';
    }

    private isHexDigit(ch: string): boolean {
        return this.isDigit(ch) || (ch >= 'A' && ch <= 'F') || (ch >= 'a' && ch <= 'f');
    }

    private isAlpha(ch: string): boolean {
        return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch === '_';
    }

    private isAlphaNumeric(ch: string): boolean {
        return this.isAlpha(ch) || this.isDigit(ch);
    }
}
