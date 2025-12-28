' ================================
' ブロック崩し (BREAKOUT)
' プチコン4用サンプルプログラム
' ================================
' 操作方法:
'   左右キー: パドル移動
'   Aボタン: ボール発射/リスタート
' ================================

OPTION STRICT
ACLS

' 定数定義
CONST SW = 320  ' 画面幅
CONST SH = 240  ' 画面高さ
CONST PW = 48   ' パドル幅
CONST PH = 8    ' パドル高さ
CONST BR = 4    ' ボール半径
CONST BW = 32   ' ブロック幅
CONST BH = 12   ' ブロック高さ
CONST COLS = 10 ' ブロック列数
CONST ROWS = 5  ' ブロック行数

' 変数宣言
DIM PADDLE_X
DIM BALL_X!, BALL_Y!, BALL_VX!, BALL_VY!
DIM BLOCKS[COLS, ROWS]
DIM SCORE, LIVES, REMAIN
DIM BALL_ACTIVE, GAME_OVER

' 色定義
DIM BLOCK_COLORS[5]
BLOCK_COLORS[0] = #FF0000
BLOCK_COLORS[1] = #FF8800
BLOCK_COLORS[2] = #FFFF00
BLOCK_COLORS[3] = #00FF00
BLOCK_COLORS[4] = #00FFFF

' 初期化
GOSUB @GAME_INIT

' メインループ
LOOP
  VSYNC
  IF GAME_OVER THEN
    GOSUB @DRAW_GAMEOVER
    IF BUTTON(2) AND 16 THEN GOSUB @GAME_INIT
  ELSE
    GOSUB @INPUT
    GOSUB @UPDATE
    GOSUB @DRAW
    IF REMAIN == 0 THEN
      GOSUB @NEXT_STAGE
    ENDIF
  ENDIF
ENDLOOP

' ===== ゲーム初期化 =====
@GAME_INIT
ACLS
SCORE = 0
LIVES = 3
GAME_OVER = FALSE
GOSUB @INIT_STAGE
RETURN

' ===== ステージ初期化 =====
@INIT_STAGE
PADDLE_X = SW / 2 - PW / 2
BALL_X! = SW / 2
BALL_Y! = SH - 40
BALL_VX! = 0
BALL_VY! = 0
BALL_ACTIVE = FALSE
REMAIN = COLS * ROWS

' ブロック配置
FOR Y = 0 TO ROWS - 1
  FOR X = 0 TO COLS - 1
    BLOCKS[X, Y] = 1
  NEXT
NEXT
RETURN

' ===== 次のステージ =====
@NEXT_STAGE
SCORE = SCORE + 1000
GOSUB @INIT_STAGE
RETURN

' ===== 入力処理 =====
@INPUT
VAR B = BUTTON(0)

' パドル移動
IF B AND 4 THEN PADDLE_X = PADDLE_X - 6
IF B AND 8 THEN PADDLE_X = PADDLE_X + 6

' 範囲制限
IF PADDLE_X < 0 THEN PADDLE_X = 0
IF PADDLE_X > SW - PW THEN PADDLE_X = SW - PW

' ボール発射
IF NOT BALL_ACTIVE AND (BUTTON(2) AND 16) THEN
  BALL_ACTIVE = TRUE
  BALL_VX! = (RND(100) - 50) / 25.0
  BALL_VY! = -4.0
  BALL_X! = PADDLE_X + PW / 2
  BALL_Y! = SH - 40
ENDIF
RETURN

' ===== 更新処理 =====
@UPDATE
IF NOT BALL_ACTIVE THEN
  BALL_X! = PADDLE_X + PW / 2
  BALL_Y! = SH - 40
  RETURN
ENDIF

' ボール移動
BALL_X! = BALL_X! + BALL_VX!
BALL_Y! = BALL_Y! + BALL_VY!

' 壁反射
IF BALL_X! <= BR THEN
  BALL_X! = BR
  BALL_VX! = -BALL_VX!
ENDIF
IF BALL_X! >= SW - BR THEN
  BALL_X! = SW - BR
  BALL_VX! = -BALL_VX!
ENDIF
IF BALL_Y! <= BR THEN
  BALL_Y! = BR
  BALL_VY! = -BALL_VY!
ENDIF

' 下に落ちた
IF BALL_Y! >= SH THEN
  LIVES = LIVES - 1
  IF LIVES <= 0 THEN
    GAME_OVER = TRUE
  ELSE
    BALL_ACTIVE = FALSE
  ENDIF
  RETURN
ENDIF

' パドル反射
IF BALL_Y! + BR >= SH - 24 AND BALL_Y! - BR <= SH - 24 + PH THEN
  IF BALL_X! >= PADDLE_X AND BALL_X! <= PADDLE_X + PW THEN
    BALL_VY! = -ABS(BALL_VY!)
    ' 当たった位置で角度変更
    VAR HIT = (BALL_X! - PADDLE_X) / PW - 0.5
    BALL_VX! = HIT * 6.0
    BEEP 1
  ENDIF
ENDIF

' ブロック衝突
FOR Y = 0 TO ROWS - 1
  FOR X = 0 TO COLS - 1
    IF BLOCKS[X, Y] > 0 THEN
      VAR BX = X * BW
      VAR BY = 30 + Y * BH
      IF BALL_X! + BR > BX AND BALL_X! - BR < BX + BW THEN
        IF BALL_Y! + BR > BY AND BALL_Y! - BR < BY + BH THEN
          BLOCKS[X, Y] = 0
          REMAIN = REMAIN - 1
          SCORE = SCORE + (ROWS - Y) * 10
          BALL_VY! = -BALL_VY!
          BEEP 0
        ENDIF
      ENDIF
    ENDIF
  NEXT
NEXT
RETURN

' ===== 描画 =====
@DRAW
' 背景クリア
GFILL 0, 0, SW - 1, SH - 1, #000022

' ブロック描画
FOR Y = 0 TO ROWS - 1
  FOR X = 0 TO COLS - 1
    IF BLOCKS[X, Y] > 0 THEN
      VAR BX = X * BW
      VAR BY = 30 + Y * BH
      GFILL BX + 1, BY + 1, BX + BW - 2, BY + BH - 2, BLOCK_COLORS[Y]
    ENDIF
  NEXT
NEXT

' パドル描画
GFILL PADDLE_X, SH - 24, PADDLE_X + PW - 1, SH - 24 + PH - 1, #FFFFFF

' ボール描画
GCIRCLE BALL_X!, BALL_Y!, BR, #FFFFFF, TRUE

' 情報表示
LOCATE 0, 0 : PRINT "SCORE: "; SCORE
LOCATE 20, 0 : PRINT "LIVES: "; LIVES

' ボール未発射時のガイド
IF NOT BALL_ACTIVE THEN
  LOCATE 10, 14 : PRINT "PRESS A TO START"
ENDIF
RETURN

' ===== ゲームオーバー描画 =====
@DRAW_GAMEOVER
GFILL 80, 90, 240, 150, #000000
GBOX 80, 90, 240, 150, #FF0000
LOCATE 13, 11 : PRINT "GAME OVER"
LOCATE 11, 13 : PRINT "SCORE: "; SCORE
LOCATE 9, 15 : PRINT "PRESS A TO RETRY"
RETURN
