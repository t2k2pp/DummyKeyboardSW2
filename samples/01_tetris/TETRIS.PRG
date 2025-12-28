' ================================
' テトリス (TETRIS)
' プチコン4用サンプルプログラム
' ================================
' 操作方法:
'   左右キー: 移動
'   上キー: 回転
'   下キー: 落下加速
'   Aボタン: ハードドロップ
' ================================

OPTION STRICT
ACLS

' 定数定義
CONST FW = 10  ' フィールド幅
CONST FH = 20  ' フィールド高さ
CONST BS = 8   ' ブロックサイズ
CONST OX = 80  ' 描画オフセットX
CONST OY = 16  ' 描画オフセットY

' 変数宣言
DIM FIELD[FW, FH]
DIM MINO[4, 4]
DIM NEXT_MINO[4, 4]
DIM MX, MY, MT, NT
DIM SCORE, LEVEL, LINES
DIM FALL_TIME, FALL_SPEED
DIM GAME_OVER

' ミノ形状データ (7種×4回転×4×4)
DIM SHAPES[7, 4, 4, 4]

' 色定義
DIM COLORS[8]
COLORS[0] = #000000  ' 空
COLORS[1] = #00FFFF  ' I - シアン
COLORS[2] = #FFFF00  ' O - 黄
COLORS[3] = #800080  ' T - 紫
COLORS[4] = #00FF00  ' S - 緑
COLORS[5] = #FF0000  ' Z - 赤
COLORS[6] = #0000FF  ' J - 青
COLORS[7] = #FFA500  ' L - オレンジ

' 初期化
GOSUB @INIT_SHAPES
GOSUB @GAME_INIT

' メインループ
LOOP
  VSYNC
  IF GAME_OVER THEN
    GOSUB @DRAW_GAMEOVER
    IF BUTTON(1) AND 16 THEN GOSUB @GAME_INIT
  ELSE
    GOSUB @INPUT
    GOSUB @UPDATE
    GOSUB @DRAW
  ENDIF
ENDLOOP

' ===== ゲーム初期化 =====
@GAME_INIT
ACLS
SCORE = 0
LEVEL = 1
LINES = 0
FALL_TIME = 0
FALL_SPEED = 30
GAME_OVER = FALSE

' フィールドクリア
FOR Y = 0 TO FH - 1
  FOR X = 0 TO FW - 1
    FIELD[X, Y] = 0
  NEXT
NEXT

' 最初のミノ生成
NT = RND(7) + 1
GOSUB @NEW_MINO
RETURN

' ===== 新しいミノ生成 =====
@NEW_MINO
MT = NT
NT = RND(7) + 1
MX = FW / 2 - 2
MY = 0

' ミノ形状をコピー
FOR Y = 0 TO 3
  FOR X = 0 TO 3
    MINO[X, Y] = SHAPES[MT - 1, 0, Y, X]
  NEXT
NEXT

' 衝突チェック（ゲームオーバー判定）
IF GOSUB(@CHECK_COLLISION) THEN GAME_OVER = TRUE
RETURN

' ===== 入力処理 =====
@INPUT
VAR B = BUTTON(1)
VAR R = BUTTON(2)

' 左移動
IF R AND 4 THEN
  MX = MX - 1
  IF GOSUB(@CHECK_COLLISION) THEN MX = MX + 1
ENDIF

' 右移動
IF R AND 8 THEN
  MX = MX + 1
  IF GOSUB(@CHECK_COLLISION) THEN MX = MX - 1
ENDIF

' 回転
IF R AND 1 THEN
  GOSUB @ROTATE
ENDIF

' 落下加速
IF B AND 2 THEN
  FALL_SPEED = 2
ELSE
  FALL_SPEED = 30 - LEVEL * 2
  IF FALL_SPEED < 2 THEN FALL_SPEED = 2
ENDIF

' ハードドロップ
IF R AND 16 THEN
  WHILE NOT GOSUB(@CHECK_COLLISION)
    MY = MY + 1
  WEND
  MY = MY - 1
  FALL_TIME = FALL_SPEED
ENDIF
RETURN

' ===== 更新処理 =====
@UPDATE
INC FALL_TIME
IF FALL_TIME >= FALL_SPEED THEN
  FALL_TIME = 0
  MY = MY + 1
  IF GOSUB(@CHECK_COLLISION) THEN
    MY = MY - 1
    GOSUB @FIX_MINO
    GOSUB @CHECK_LINES
    GOSUB @NEW_MINO
  ENDIF
ENDIF
RETURN

' ===== 衝突判定 =====
@CHECK_COLLISION
FOR Y = 0 TO 3
  FOR X = 0 TO 3
    IF MINO[X, Y] > 0 THEN
      VAR PX = MX + X
      VAR PY = MY + Y
      IF PX < 0 OR PX >= FW OR PY >= FH THEN RETURN TRUE
      IF PY >= 0 AND FIELD[PX, PY] > 0 THEN RETURN TRUE
    ENDIF
  NEXT
NEXT
RETURN FALSE

' ===== ミノ固定 =====
@FIX_MINO
FOR Y = 0 TO 3
  FOR X = 0 TO 3
    IF MINO[X, Y] > 0 THEN
      VAR PX = MX + X
      VAR PY = MY + Y
      IF PY >= 0 AND PY < FH AND PX >= 0 AND PX < FW THEN
        FIELD[PX, PY] = MT
      ENDIF
    ENDIF
  NEXT
NEXT
RETURN

' ===== ライン消去チェック =====
@CHECK_LINES
VAR CLEARED = 0
FOR Y = FH - 1 TO 0 STEP -1
  VAR FULL = TRUE
  FOR X = 0 TO FW - 1
    IF FIELD[X, Y] == 0 THEN FULL = FALSE : BREAK
  NEXT
  IF FULL THEN
    INC CLEARED
    ' ラインを下にずらす
    FOR Y2 = Y TO 1 STEP -1
      FOR X = 0 TO FW - 1
        FIELD[X, Y2] = FIELD[X, Y2 - 1]
      NEXT
    NEXT
    FOR X = 0 TO FW - 1
      FIELD[X, 0] = 0
    NEXT
    INC Y  ' 同じ行を再チェック
  ENDIF
NEXT

' スコア計算
IF CLEARED > 0 THEN
  LINES = LINES + CLEARED
  VAR BONUS = 0
  IF CLEARED == 1 THEN BONUS = 100
  IF CLEARED == 2 THEN BONUS = 300
  IF CLEARED == 3 THEN BONUS = 500
  IF CLEARED == 4 THEN BONUS = 800
  SCORE = SCORE + BONUS * LEVEL
  LEVEL = LINES / 10 + 1
ENDIF
RETURN

' ===== 回転 =====
@ROTATE
DIM TEMP[4, 4]
FOR Y = 0 TO 3
  FOR X = 0 TO 3
    TEMP[3 - Y, X] = MINO[X, Y]
  NEXT
NEXT
' 仮適用
DIM BACKUP[4, 4]
FOR Y = 0 TO 3
  FOR X = 0 TO 3
    BACKUP[X, Y] = MINO[X, Y]
    MINO[X, Y] = TEMP[X, Y]
  NEXT
NEXT
' 衝突なら戻す
IF GOSUB(@CHECK_COLLISION) THEN
  FOR Y = 0 TO 3
    FOR X = 0 TO 3
      MINO[X, Y] = BACKUP[X, Y]
    NEXT
  NEXT
ENDIF
RETURN

' ===== 描画 =====
@DRAW
' 背景クリア
GFILL 0, 0, 319, 239, #111111

' フィールド枠
GBOX OX - 2, OY - 2, OX + FW * BS + 1, OY + FH * BS + 1, #FFFFFF

' フィールド描画
FOR Y = 0 TO FH - 1
  FOR X = 0 TO FW - 1
    VAR C = FIELD[X, Y]
    IF C > 0 THEN
      GFILL OX + X * BS, OY + Y * BS, OX + X * BS + BS - 1, OY + Y * BS + BS - 1, COLORS[C]
    ENDIF
  NEXT
NEXT

' 現在のミノ描画
FOR Y = 0 TO 3
  FOR X = 0 TO 3
    IF MINO[X, Y] > 0 THEN
      VAR PX = OX + (MX + X) * BS
      VAR PY = OY + (MY + Y) * BS
      IF PY >= OY THEN
        GFILL PX, PY, PX + BS - 1, PY + BS - 1, COLORS[MT]
      ENDIF
    ENDIF
  NEXT
NEXT

' 情報表示
LOCATE 24, 1 : PRINT "SCORE"
LOCATE 24, 2 : PRINT SCORE
LOCATE 24, 4 : PRINT "LEVEL"
LOCATE 24, 5 : PRINT LEVEL
LOCATE 24, 7 : PRINT "LINES"
LOCATE 24, 8 : PRINT LINES
LOCATE 24, 10 : PRINT "NEXT"

' NEXTミノ描画
FOR Y = 0 TO 3
  FOR X = 0 TO 3
    IF SHAPES[NT - 1, 0, Y, X] > 0 THEN
      GFILL 200 + X * BS, 100 + Y * BS, 200 + X * BS + BS - 1, 100 + Y * BS + BS - 1, COLORS[NT]
    ENDIF
  NEXT
NEXT
RETURN

' ===== ゲームオーバー描画 =====
@DRAW_GAMEOVER
LOCATE 12, 10 : PRINT "GAME OVER"
LOCATE 10, 12 : PRINT "SCORE: "; SCORE
LOCATE 8, 14 : PRINT "PRESS A TO RESTART"
RETURN

' ===== ミノ形状初期化 =====
@INIT_SHAPES
' I-ミノ
DATA 0,0,0,0, 1,1,1,1, 0,0,0,0, 0,0,0,0
' O-ミノ  
DATA 0,1,1,0, 0,1,1,0, 0,0,0,0, 0,0,0,0
' T-ミノ
DATA 0,1,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0
' S-ミノ
DATA 0,1,1,0, 1,1,0,0, 0,0,0,0, 0,0,0,0
' Z-ミノ
DATA 1,1,0,0, 0,1,1,0, 0,0,0,0, 0,0,0,0
' J-ミノ
DATA 1,0,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0
' L-ミノ
DATA 0,0,1,0, 1,1,1,0, 0,0,0,0, 0,0,0,0

RESTORE @INIT_SHAPES
FOR T = 0 TO 6
  FOR Y = 0 TO 3
    FOR X = 0 TO 3
      READ SHAPES[T, 0, Y, X]
    NEXT
  NEXT
NEXT
RETURN
