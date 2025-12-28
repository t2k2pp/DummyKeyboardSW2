// SmileBASIC AST Type Definitions

// ===== トークン =====
export type TokenType =
    | 'NUMBER' | 'STRING' | 'IDENTIFIER' | 'KEYWORD' | 'LABEL'
    | 'OPERATOR' | 'LPAREN' | 'RPAREN' | 'LBRACKET' | 'RBRACKET'
    | 'COMMA' | 'SEMICOLON' | 'COLON' | 'NEWLINE' | 'COMMENT' | 'EOF';

export interface Token {
    type: TokenType;
    value: string;
    line: number;
    column: number;
}

// ===== AST ノード =====
export interface Program {
    type: 'Program';
    body: Statement[];
}

export type Statement =
    | LabelStmt
    | VarDeclStmt
    | DimDeclStmt
    | ConstDeclStmt
    | AssignmentStmt
    | PrintStmt
    | LocateStmt
    | ColorStmt
    | GfillStmt
    | GlineStmt
    | GboxStmt
    | GcircleStmt
    | IfStmt
    | ForStmt
    | WhileStmt
    | LoopStmt
    | GosubStmt
    | ReturnStmt
    | OnGosubStmt
    | IncStmt
    | DecStmt
    | BeepStmt
    | VsyncStmt
    | BreakStmt
    | AclsStmt
    | DataStmt
    | ReadStmt
    | RestoreStmt
    | ExpressionStmt;

// ===== 文 =====
export interface LabelStmt { type: 'Label'; name: string; line: number; }
export interface VarDeclStmt { type: 'VarDecl'; name: string; value?: Expression; }
export interface DimDeclStmt { type: 'DimDecl'; declarations: { name: string; sizes: Expression[] }[]; }
export interface ConstDeclStmt { type: 'ConstDecl'; name: string; value: Expression; }
export interface AssignmentStmt { type: 'Assignment'; target: LValue; value: Expression; }
export interface PrintStmt { type: 'Print'; args: Expression[]; newline: boolean; }
export interface LocateStmt { type: 'Locate'; x: Expression; y: Expression; }
export interface ColorStmt { type: 'Color'; color: Expression; }
export interface GfillStmt { type: 'Gfill'; x1: Expression; y1: Expression; x2: Expression; y2: Expression; color: Expression; }
export interface GlineStmt { type: 'Gline'; x1: Expression; y1: Expression; x2: Expression; y2: Expression; color: Expression; }
export interface GboxStmt { type: 'Gbox'; x1: Expression; y1: Expression; x2: Expression; y2: Expression; color: Expression; }
export interface GcircleStmt { type: 'Gcircle'; x: Expression; y: Expression; r: Expression; color: Expression; fill?: Expression; }
export interface IfStmt { type: 'If'; condition: Expression; thenBody: Statement[]; elseBody?: Statement[]; }
export interface ForStmt { type: 'For'; variable: string; start: Expression; end: Expression; step?: Expression; body: Statement[]; }
export interface WhileStmt { type: 'While'; condition: Expression; body: Statement[]; }
export interface LoopStmt { type: 'Loop'; body: Statement[]; }
export interface GosubStmt { type: 'Gosub'; label: string; }
export interface ReturnStmt { type: 'Return'; value?: Expression; }
export interface OnGosubStmt { type: 'OnGosub'; index: Expression; labels: string[]; }
export interface IncStmt { type: 'Inc'; target: LValue; }
export interface DecStmt { type: 'Dec'; target: LValue; }
export interface BeepStmt { type: 'Beep'; sound?: Expression; }
export interface VsyncStmt { type: 'Vsync'; }
export interface BreakStmt { type: 'Break'; }
export interface AclsStmt { type: 'Acls'; }
export interface DataStmt { type: 'Data'; values: Expression[]; line: number; }
export interface ReadStmt { type: 'Read'; variables: string[]; }
export interface RestoreStmt { type: 'Restore'; label?: string; }
export interface ExpressionStmt { type: 'ExpressionStmt'; expression: Expression; }

// ===== 左辺値 =====
export type LValue =
    | { type: 'Identifier'; name: string }
    | { type: 'ArrayAccess'; name: string; indices: Expression[] };

// ===== 式 =====
export type Expression =
    | NumberLiteral
    | StringLiteral
    | BooleanLiteral
    | Identifier
    | ArrayAccess
    | BinaryExpr
    | UnaryExpr
    | CallExpr
    | GosubExpr;

export interface NumberLiteral { type: 'Number'; value: number; }
export interface StringLiteral { type: 'String'; value: string; }
export interface BooleanLiteral { type: 'Boolean'; value: boolean; }
export interface Identifier { type: 'Identifier'; name: string; }
export interface ArrayAccess { type: 'ArrayAccess'; name: string; indices: Expression[]; }
export interface BinaryExpr { type: 'Binary'; op: string; left: Expression; right: Expression; }
export interface UnaryExpr { type: 'Unary'; op: string; operand: Expression; }
export interface CallExpr { type: 'Call'; name: string; args: Expression[]; }
export interface GosubExpr { type: 'GosubExpr'; label: string; } // GOSUB戻り値用

// ===== 値型 =====
export type Value = number | string | boolean;
export type ArrayValue = Value[];
