' ================================
' デジタル時計 (CLOCK)
' プチコン4用サンプルプログラム
' ================================
' 操作方法:
'   Aボタン: 表示モード切替
'   Bボタン: カラーテーマ切替
' ================================

OPTION STRICT
ACLS

' 変数宣言
DIM MODE  ' 0=デジタル, 1=アナログ
DIM THEME
DIM THEMES[5, 3]  ' 5テーマ x 3色（背景、文字、アクセント）

' テーマ定義
THEMES[0, 0] = #000000 : THEMES[0, 1] = #00FF00 : THEMES[0, 2] = #008800  ' グリーン
THEMES[1, 0] = #000022 : THEMES[1, 1] = #00FFFF : THEMES[1, 2] = #0088AA  ' シアン
THEMES[2, 0] = #220000 : THEMES[2, 1] = #FF4444 : THEMES[2, 2] = #AA0000  ' レッド
THEMES[3, 0] = #111111 : THEMES[3, 1] = #FFFFFF : THEMES[3, 2] = #888888  ' モノクロ
THEMES[4, 0] = #001100 : THEMES[4, 1] = #FFFF00 : THEMES[4, 2] = #888800  ' イエロー

' 初期化
GOSUB @INIT

' メインループ
LOOP
  VSYNC
  GOSUB @INPUT
  GOSUB @DRAW
ENDLOOP

' ===== 初期化 =====
@INIT
ACLS
MODE = 0
THEME = 0
RETURN

' ===== 入力処理 =====
@INPUT
VAR B = BUTTON(2)

' モード切替
IF B AND 16 THEN
  MODE = 1 - MODE
  BEEP 0
ENDIF

' テーマ切替
IF B AND 32 THEN
  THEME = (THEME + 1) MOD 5
  BEEP 1
ENDIF
RETURN

' ===== 描画 =====
@DRAW
VAR BG = THEMES[THEME, 0]
VAR FG = THEMES[THEME, 1]
VAR AC = THEMES[THEME, 2]

' 背景クリア
GFILL 0, 0, 319, 239, BG

' 現在時刻取得
VAR H = VAL(TIME$[0, 2])
VAR M = VAL(TIME$[3, 2])
VAR S = VAL(TIME$[6, 2])

IF MODE == 0 THEN
  GOSUB @DRAW_DIGITAL
ELSE
  GOSUB @DRAW_ANALOG
ENDIF

' 日付表示
LOCATE 11, 28 : COLOR AC : PRINT DATE$
COLOR #FFFFFF

' 操作ガイド
LOCATE 1, 29 : COLOR AC : PRINT "A:MODE B:THEME"
COLOR #FFFFFF
RETURN

' ===== デジタル時計描画 =====
@DRAW_DIGITAL
VAR FG = THEMES[THEME, 1]
VAR AC = THEMES[THEME, 2]

' 時刻文字列
VAR TIME_STR$ = FORMAT$("%02d:%02d:%02d", H, M, S)

' 大きな文字で表示（セグメント風）
VAR SX = 40
VAR SY = 60
VAR CHAR_W = 30
VAR CHAR_H = 60

FOR I = 0 TO LEN(TIME_STR$) - 1
  VAR CH$ = MID$(TIME_STR$, I, 1)
  VAR CX = SX + I * CHAR_W
  
  IF CH$ == ":" THEN
    ' コロン（点滅）
    IF S MOD 2 == 0 THEN
      GCIRCLE CX + 5, SY + 15, 4, FG, TRUE
      GCIRCLE CX + 5, SY + 45, 4, FG, TRUE
    ENDIF
  ELSE
    ' 数字をセグメント風に描画
    GOSUB @DRAW_DIGIT
  ENDIF
NEXT

' 秒のバー
VAR BAR_W = S * 4
GFILL 40, 140, 40 + BAR_W, 150, FG
GBOX 40, 140, 280, 150, AC
RETURN

' ===== 数字描画（セグメント風） =====
@DRAW_DIGIT
VAR D = VAL(CH$)
VAR W = 24
VAR H2 = 25

' セグメントパターン（7セグメント: 上、右上、右下、下、左下、左上、中）
DIM SEG[10]
SEG[0] = %1110111  ' 0
SEG[1] = %0100100  ' 1
SEG[2] = %1011101  ' 2
SEG[3] = %1101101  ' 3
SEG[4] = %0101110  ' 4
SEG[5] = %1101011  ' 5
SEG[6] = %1111011  ' 6
SEG[7] = %0100101  ' 7
SEG[8] = %1111111  ' 8
SEG[9] = %1101111  ' 9

VAR PAT = SEG[D]

' 上
IF PAT AND %0000001 THEN GFILL CX + 2, SY, CX + W - 2, SY + 4, FG
' 右上
IF PAT AND %0000010 THEN GFILL CX + W - 4, SY + 2, CX + W, SY + H2 - 2, FG
' 右下
IF PAT AND %0000100 THEN GFILL CX + W - 4, SY + H2 + 2, CX + W, SY + H2 * 2 - 2, FG
' 下
IF PAT AND %0001000 THEN GFILL CX + 2, SY + H2 * 2 - 4, CX + W - 2, SY + H2 * 2, FG
' 左下
IF PAT AND %0010000 THEN GFILL CX, SY + H2 + 2, CX + 4, SY + H2 * 2 - 2, FG
' 左上
IF PAT AND %0100000 THEN GFILL CX, SY + 2, CX + 4, SY + H2 - 2, FG
' 中
IF PAT AND %1000000 THEN GFILL CX + 2, SY + H2 - 2, CX + W - 2, SY + H2 + 2, FG
RETURN

' ===== アナログ時計描画 =====
@DRAW_ANALOG
VAR FG = THEMES[THEME, 1]
VAR AC = THEMES[THEME, 2]

VAR CX = 160
VAR CY = 110
VAR R = 90

' 文字盤
GCIRCLE CX, CY, R, FG
GCIRCLE CX, CY, R - 2, AC

' 目盛り
FOR I = 0 TO 11
  VAR A! = I * 30 * PI / 180 - PI / 2
  VAR X1 = CX + COS(A!) * (R - 10)
  VAR Y1 = CY + SIN(A!) * (R - 10)
  VAR X2 = CX + COS(A!) * (R - 5)
  VAR Y2 = CY + SIN(A!) * (R - 5)
  GLINE X1, Y1, X2, Y2, FG
  
  ' 数字
  VAR NX = CX + COS(A!) * (R - 22) - 4
  VAR NY = CY + SIN(A!) * (R - 22) - 4
  VAR NUM = I
  IF NUM == 0 THEN NUM = 12
  LOCATE NX / 8, NY / 8 : COLOR AC : PRINT NUM
NEXT

' 時針
VAR HA! = (H MOD 12 + M / 60.0) * 30 * PI / 180 - PI / 2
VAR HX = CX + COS(HA!) * 50
VAR HY = CY + SIN(HA!) * 50
GLINE CX, CY, HX, HY, FG
GLINE CX + 1, CY, HX + 1, HY, FG
GLINE CX, CY + 1, HX, HY + 1, FG

' 分針
VAR MA! = (M + S / 60.0) * 6 * PI / 180 - PI / 2
VAR MX = CX + COS(MA!) * 70
VAR MY = CY + SIN(MA!) * 70
GLINE CX, CY, MX, MY, FG

' 秒針
VAR SA! = S * 6 * PI / 180 - PI / 2
VAR SSX = CX + COS(SA!) * 75
VAR SSY = CY + SIN(SA!) * 75
GLINE CX, CY, SSX, SSY, #FF0000

' 中心点
GCIRCLE CX, CY, 5, FG, TRUE

COLOR #FFFFFF
RETURN
