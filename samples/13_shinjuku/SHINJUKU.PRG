' ================================
' 新宿ダンジョン 【完全版】
' 8番出口風・観察型脱出ゲーム
' プチコン4用サンプルプログラム
' ================================
' プレイ時間: 約30分
' ステージ数: 20（地下10階から地上へ）
' 異変パターン: 20種類
' ================================

OPTION STRICT
ACLS

' 定数
CONST STAGE_COUNT = 20
CONST TEXT_SPEED = 2
CONST MAX_ANOMALY_TYPES = 20

' 変数
DIM STAGE, MISTAKES, CLEARED
DIM TEXT$[20], LINE_COUNT
DIM HAS_ANOMALY, ANOMALY_TYPE
DIM CHOICE, TYPING_LINE, TYPING_POS
DIM GAME_STATE
DIM FLOOR  ' 現在の階層 (B10〜B1)
DIM AREA_TYPE  ' 0=通路, 1=広場, 2=階段, 3=店舗街
DIM STRESS  ' ストレス値
DIM FOUND_CLUES  ' 発見した手がかり

DIM STAGE_ANOMALY[STAGE_COUNT]

' 初期化
GOSUB @INIT_GAME

' メインループ
LOOP
  VSYNC
  GOSUB @UPDATE
  GOSUB @DRAW
ENDLOOP

' ===== ゲーム初期化 =====
@INIT_GAME
ACLS
STAGE = 0
MISTAKES = 0
CLEARED = FALSE
GAME_STATE = 0
CHOICE = 0
FLOOR = 10
STRESS = 0
FOUND_CLUES = 0

FOR I = 0 TO STAGE_COUNT - 1
  STAGE_ANOMALY[I] = RND(2)
NEXT
RETURN

' ===== ステージ開始 =====
@START_STAGE
TYPING_LINE = 0
TYPING_POS = 0
CHOICE = 0

' 階層更新
FLOOR = 10 - STAGE / 2

' エリアタイプ
AREA_TYPE = STAGE MOD 4

HAS_ANOMALY = STAGE_ANOMALY[STAGE]
ANOMALY_TYPE = RND(MAX_ANOMALY_TYPES)

GOSUB @GENERATE_SCENE
RETURN

' ===== シーン生成 =====
@GENERATE_SCENE
LINE_COUNT = 0

' エリア別基本描写
ON AREA_TYPE GOSUB @DESC_CORRIDOR, @DESC_PLAZA, @DESC_STAIRS, @DESC_SHOPS

' 階層特有の描写
GOSUB @DESC_FLOOR_DETAIL

' 異変の有無
IF HAS_ANOMALY THEN
  GOSUB @ADD_ANOMALY
ELSE
  GOSUB @ADD_NORMAL
ENDIF

' 選択肢
VAR L = LINE_COUNT
TEXT$[L] = ""
TEXT$[L + 1] = "【どうする？】"
TEXT$[L + 2] = "　▶ 先へ進む"
TEXT$[L + 3] = "　　 引き返す"
LINE_COUNT = L + 4
RETURN

' ===== 通路 =====
@DESC_CORRIDOR
TEXT$[0] = "　長い地下通路を歩いている。"
TEXT$[1] = ""
VAR N = RND(4)
IF N == 0 THEN
  TEXT$[2] = "　蛍光灯が等間隔に並び、"
  TEXT$[3] = "　無機質な光を放っている。"
ELSEIF N == 1 THEN
  TEXT$[2] = "　壁はタイル張りで、"
  TEXT$[3] = "　ところどころ剥がれている。"
ELSEIF N == 2 THEN
  TEXT$[2] = "　足音が反響して、"
  TEXT$[3] = "　自分以外の誰かがいるようにも聞こえる。"
ELSE
  TEXT$[2] = "　配管がむき出しになっている天井。"
  TEXT$[3] = "　ここまで深い階層は初めてだ。"
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 広場 =====
@DESC_PLAZA
TEXT$[0] = "　広い地下広場に出た。"
TEXT$[1] = ""
VAR N = RND(4)
IF N == 0 THEN
  TEXT$[2] = "　いくつかの通路が放射状に伸びている。"
  TEXT$[3] = "　中央には古い噴水がある。水は出ていない。"
ELSEIF N == 1 THEN
  TEXT$[2] = "　ベンチが並んでいるが、座っている人はいない。"
  TEXT$[3] = "　深夜だから当然だ...と思いたい。"
ELSEIF N == 2 THEN
  TEXT$[2] = "　天井が高く、声が反響する。"
  TEXT$[3] = "　自分の呼吸音さえ大きく聞こえる。"
ELSE
  TEXT$[2] = "　案内板があるが、どの行き先も"
  TEXT$[3] = "　聞いたことのない名前だ。"
  INC STRESS
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 階段 =====
@DESC_STAIRS
TEXT$[0] = "　階段が見えてきた。"
TEXT$[1] = ""
IF FLOOR > 5 THEN
  TEXT$[2] = "　上へ続いている。"
  TEXT$[3] = "　地上に近づいているはずだ。"
ELSE
  TEXT$[2] = "　出口はもうすぐかもしれない。"
  TEXT$[3] = "　足取りが自然と速くなる。"
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 店舗街 =====
@DESC_SHOPS
TEXT$[0] = "　シャッターの閉まった店舗が並んでいる。"
TEXT$[1] = ""
VAR N = RND(4)
IF N == 0 THEN
  TEXT$[2] = "　飲食店やブティックが軒を連ねる。"
  TEXT$[3] = "　昼間は賑わっているのだろう。"
ELSEIF N == 1 THEN
  TEXT$[2] = "　閉店したまま放置された店もある。"
  TEXT$[3] = "　テナント募集の張り紙が色褪せている。"
ELSEIF N == 2 THEN
  TEXT$[2] = "　ウィンドウに商品が飾られている。"
  TEXT$[3] = "　マネキンの視線を感じる...気のせいだ。"
ELSE
  TEXT$[2] = "　かつての飲み屋街だろうか。"
  TEXT$[3] = "　今は物音ひとつしない。"
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 階層詳細 =====
@DESC_FLOOR_DETAIL
VAR L = LINE_COUNT
IF FLOOR >= 8 THEN
  TEXT$[L] = "　この深さまで来る人はいない。"
  TEXT$[L + 1] = "　埃っぽい空気が肺を刺す。"
ELSEIF FLOOR >= 5 THEN
  TEXT$[L] = "　少し空気が変わった気がする。"
  TEXT$[L + 1] = "　地上が近づいているのだろうか。"
ELSE
  TEXT$[L] = "　人の気配を感じる。"
  TEXT$[L + 1] = "　もうすぐ人のいる階層に出られるはず。"
ENDIF
TEXT$[L + 2] = ""
LINE_COUNT = L + 3
RETURN

' ===== 正常時 =====
@ADD_NORMAL
VAR L = LINE_COUNT
VAR N = RND(8)
IF N == 0 THEN
  TEXT$[L] = "　壁には案内板が貼られている。"
  TEXT$[L + 1] = "　「出口 →」と書かれている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　方向は合っているようだ。"
ELSEIF N == 1 THEN
  TEXT$[L] = "　自動販売機を見つけた。"
  TEXT$[L + 1] = "　普通の飲料水が並んでいる。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　電気が通っている。まだ文明の範囲内だ。"
ELSEIF N == 2 THEN
  TEXT$[L] = "　壁のポスターを確認する。"
  TEXT$[L + 1] = "　来月のイベント告知だ。日付も正常。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　ここは現実の新宿だ。"
ELSEIF N == 3 THEN
  TEXT$[L] = "　非常口のサインが光っている。"
  TEXT$[L + 1] = "　緑色のランニングマン。正常だ。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　この方向で間違いない。"
ELSEIF N == 4 THEN
  TEXT$[L] = "　壁時計を確認する。"
  TEXT$[L + 1] = "　午前3時47分。針は正常に動いている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　まだ夜明けまで時間がある。"
ELSEIF N == 5 THEN
  TEXT$[L] = "　床のタイルが整然と並んでいる。"
  TEXT$[L + 1] = "　白と灰色の市松模様。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　見慣れた新宿の地下通路だ。"
ELSEIF N == 6 THEN
  TEXT$[L] = "　防犯カメラが天井に設置されている。"
  TEXT$[L + 1] = "　赤いランプが点滅している。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　監視されている。それは安心の証だ。"
ELSE
  TEXT$[L] = "　空調の音が聞こえる。"
  TEXT$[L + 1] = "　かすかだが、確かに動いている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　この施設は管理されている。"
ENDIF
LINE_COUNT = L + 4
RETURN

' ===== 異変時 =====
@ADD_ANOMALY
VAR L = LINE_COUNT
INC STRESS

IF ANOMALY_TYPE == 0 THEN
  TEXT$[L] = "　案内板が逆さまになっている。"
  TEXT$[L + 1] = "　「← 出口」...いや、「口出 →」？"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　文字が鏡文字になっている。"
ELSEIF ANOMALY_TYPE == 1 THEN
  TEXT$[L] = "　自動販売機の飲み物が..."
  TEXT$[L + 1] = "　全て真っ黒な液体だ。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　ラベルには何も書かれていない。"
ELSEIF ANOMALY_TYPE == 2 THEN
  TEXT$[L] = "　蛍光灯が一本だけ赤く光っている。"
  TEXT$[L + 1] = "　その赤い光が脈打っている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...これは普通じゃない。"
ELSEIF ANOMALY_TYPE == 3 THEN
  TEXT$[L] = "　壁のポスターの人物が..."
  TEXT$[L + 1] = "　全員こちらを見ている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　目が動いた気がする。"
ELSEIF ANOMALY_TYPE == 4 THEN
  TEXT$[L] = "　床に足跡がある。"
  TEXT$[L + 1] = "　一人分の足跡が途中で消えている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　まるで消えたかのように。"
ELSEIF ANOMALY_TYPE == 5 THEN
  TEXT$[L] = "　非常口のサインが点滅している。"
  TEXT$[L + 1] = "　人が逆向きに走っている図だ。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　出口から逃げている？"
ELSEIF ANOMALY_TYPE == 6 THEN
  TEXT$[L] = "　時計が逆回転している。"
  TEXT$[L + 1] = "　しかも異常に速い。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　時間が巻き戻っている？"
ELSEIF ANOMALY_TYPE == 7 THEN
  TEXT$[L] = "　通路の先に人影が見える。"
  TEXT$[L + 1] = "　手招きをしているが、影がない。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　ついて行ってはいけない。"
ELSEIF ANOMALY_TYPE == 8 THEN
  TEXT$[L] = "　天井から水滴が落ちてきた。"
  TEXT$[L + 1] = "　手で受けると、赤い。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...上に何がある？"
ELSEIF ANOMALY_TYPE == 9 THEN
  TEXT$[L] = "　壁に無数の手形がついている。"
  TEXT$[L + 1] = "　どれも同じ大きさ、同じ形。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　引きずり込まれたかのよう。"
ELSEIF ANOMALY_TYPE == 10 THEN
  TEXT$[L] = "　店舗のマネキンが..."
  TEXT$[L + 1] = "　こちらを向いている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　さっきは横を向いていたはず。"
ELSEIF ANOMALY_TYPE == 11 THEN
  TEXT$[L] = "　床のタイルの模様が..."
  TEXT$[L + 1] = "　顔のように見える。苦悶の表情。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　目を逸らして歩こう。"
ELSEIF ANOMALY_TYPE == 12 THEN
  TEXT$[L] = "　携帯電話が震えた。"
  TEXT$[L + 1] = "　画面には『ミツケタ』と表示されている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　圏外のはずなのに..."
ELSEIF ANOMALY_TYPE == 13 THEN
  TEXT$[L] = "　自分の影が..."
  TEXT$[L + 1] = "　自分と違う動きをしている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　見てはいけない。"
ELSEIF ANOMALY_TYPE == 14 THEN
  TEXT$[L] = "　防犯カメラのランプが..."
  TEXT$[L + 1] = "　全て一斉にこちらを向いた。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　追跡されている。"
ELSEIF ANOMALY_TYPE == 15 THEN
  TEXT$[L] = "　階段の段数がさっきと違う。"
  TEXT$[L + 1] = "　13段だったはずが、14段ある。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　増えた一段は何なのか..."
ELSEIF ANOMALY_TYPE == 16 THEN
  TEXT$[L] = "　壁の色が左右で違う。"
  TEXT$[L + 1] = "　片方だけ古く、もう片方は新しい。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　二つの空間が重なっている？"
ELSEIF ANOMALY_TYPE == 17 THEN
  TEXT$[L] = "　エレベーターの階数表示が..."
  TEXT$[L + 1] = "　B13と表示されている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　そんな階層、存在しないはず。"
ELSEIF ANOMALY_TYPE == 18 THEN
  TEXT$[L] = "　空調から声が聞こえる。"
  TEXT$[L + 1] = "　「...カエレ...カエレ...」"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　誰の声だ..."
ELSE
  TEXT$[L] = "　鏡に映った自分の顔が..."
  TEXT$[L + 1] = "　微笑んでいる。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　私は笑っていないのに。"
ENDIF
LINE_COUNT = L + 4
RETURN

' ===== 更新処理 =====
@UPDATE
VAR B = BUTTON(2)

IF GAME_STATE == 0 THEN
  IF B AND 16 THEN
    GAME_STATE = 1
    GOSUB @START_STAGE
    BEEP 0
  ENDIF
ELSEIF GAME_STATE == 1 THEN
  IF TYPING_LINE < LINE_COUNT - 4 THEN
    INC TYPING_POS
    IF TYPING_POS >= LEN(TEXT$[TYPING_LINE]) * TEXT_SPEED THEN
      TYPING_POS = 0
      INC TYPING_LINE
    ENDIF
    IF B AND 16 THEN TYPING_LINE = LINE_COUNT - 4
    RETURN
  ENDIF
  
  IF B AND 1 THEN CHOICE = 0
  IF B AND 2 THEN CHOICE = 1
  
  IF B AND 16 THEN
    GOSUB @CHECK_CHOICE
    BEEP 0
  ENDIF
ELSEIF GAME_STATE == 2 THEN
  IF B AND 16 THEN
    IF CLEARED THEN
      GAME_STATE = 3
    ELSEIF MISTAKES >= 3 THEN
      GAME_STATE = 4
    ELSE
      GAME_STATE = 1
      GOSUB @START_STAGE
    ENDIF
    BEEP 0
  ENDIF
ELSEIF GAME_STATE >= 3 THEN
  IF B AND 16 THEN
    GOSUB @INIT_GAME
    BEEP 0
  ENDIF
ENDIF
RETURN

' ===== 選択判定 =====
@CHECK_CHOICE
VAR CORRECT = FALSE

IF HAS_ANOMALY AND CHOICE == 1 THEN CORRECT = TRUE
IF NOT HAS_ANOMALY AND CHOICE == 0 THEN CORRECT = TRUE

IF CORRECT THEN
  INC STAGE
  IF STAGE >= STAGE_COUNT THEN CLEARED = TRUE
ELSE
  INC MISTAKES
ENDIF

GAME_STATE = 2
RETURN

' ===== 描画 =====
@DRAW
VAR BG
IF FLOOR >= 7 THEN
  BG = #0A0A14
ELSEIF FLOOR >= 4 THEN
  BG = #101020
ELSE
  BG = #141428
ENDIF
GFILL 0, 0, 319, 239, BG

IF GAME_STATE == 0 THEN
  GOSUB @DRAW_TITLE
ELSEIF GAME_STATE == 1 THEN
  GOSUB @DRAW_GAME
ELSEIF GAME_STATE == 2 THEN
  GOSUB @DRAW_RESULT
ELSEIF GAME_STATE == 3 THEN
  GOSUB @DRAW_CLEAR
ELSE
  GOSUB @DRAW_GAMEOVER
ENDIF
RETURN

' ===== タイトル =====
@DRAW_TITLE
GFILL 40, 25, 280, 105, #1A1A30
GBOX 40, 25, 280, 105, #6666CC

LOCATE 9, 4 : COLOR #6666CC : PRINT "新 宿 ダ ン ジ ョ ン"
LOCATE 10, 6 : COLOR #444488 : PRINT "【 完 全 版 】"
LOCATE 8, 8 : COLOR #333366 : PRINT "～ 地下10階からの脱出 ～"

LOCATE 2, 12 : COLOR #888888
PRINT "終電を逃し、地下通路を歩いていた。"
LOCATE 2, 13
PRINT "気がつけば、見知らぬ場所にいた。"
LOCATE 2, 14
PRINT "ここは新宿の地下...のはずだが..."

LOCATE 4, 17 : COLOR #FFFF00 : PRINT "【ルール】"
LOCATE 4, 18 : COLOR #AAAAAA : PRINT "異変を見つけたら → 引き返す"
LOCATE 4, 19 : PRINT "異変がなければ → 先へ進む"
LOCATE 4, 20 : PRINT "3回のミスでゲームオーバー"

LOCATE 9, 24 : COLOR #6666CC : PRINT "Aボタンでスタート"

COLOR #FFFFFF
RETURN

' ===== ゲーム =====
@DRAW_GAME
' フロア表示
LOCATE 0, 0 : COLOR #4444AA
IF FLOOR > 0 THEN
  PRINT "B"; FLOOR; "F"
ELSE
  PRINT "1F"
ENDIF

LOCATE 10, 0 : COLOR #666688
PRINT "["; STAGE + 1; "/"; STAGE_COUNT; "]"
LOCATE 26, 0 : PRINT "MISS:"; MISTAKES; "/3"

' ストレスゲージ
GFILL 255, 12, 310, 20, #222233
GFILL 255, 12, 255 + MIN(STRESS * 5, 55), 20, #FF4444

' テキストウィンドウ
GFILL 5, 30, 315, 195, #0A0A15
GBOX 5, 30, 315, 195, #444466

' テキスト
FOR I = 0 TO MIN(TYPING_LINE + 1, LINE_COUNT - 1)
  VAR TXT$ = TEXT$[I]
  
  IF I >= LINE_COUNT - 2 THEN
    VAR OPT_IDX = I - (LINE_COUNT - 2)
    IF OPT_IDX == CHOICE THEN
      TXT$ = LEFT$(TXT$, 2) + "▶" + MID$(TXT$, 4)
      COLOR #FFFF00
    ELSE
      COLOR #666666
    ENDIF
  ELSE
    COLOR #AAAACC
  ENDIF
  
  IF I == TYPING_LINE AND TYPING_LINE < LINE_COUNT - 4 THEN
    VAR SHOW_LEN = TYPING_POS / TEXT_SPEED
    TXT$ = LEFT$(TXT$, SHOW_LEN)
  ENDIF
  
  LOCATE 1, 4 + I : PRINT TXT$
NEXT

' 進行度ゲージ
GFILL 10, 215, 310, 228, #222233
GFILL 10, 215, 10 + 300 * STAGE / STAGE_COUNT, 228, #4444AA
GBOX 10, 215, 310, 228, #444466

' フロア一覧
FOR I = 0 TO 9
  VAR FX = 15 + I * 30
  IF 10 - I > FLOOR THEN
    GFILL FX, 218, FX + 25, 225, #00AA00
  ELSE
    GFILL FX, 218, FX + 25, 225, #333333
  ENDIF
NEXT

COLOR #FFFFFF
RETURN

' ===== 結果 =====
@DRAW_RESULT
VAR CORRECT = FALSE
IF HAS_ANOMALY AND CHOICE == 1 THEN CORRECT = TRUE
IF NOT HAS_ANOMALY AND CHOICE == 0 THEN CORRECT = TRUE

IF CORRECT THEN
  GFILL 60, 60, 260, 170, #1A1A44
  GBOX 60, 60, 260, 170, #6666FF
  LOCATE 14, 9 : COLOR #6666FF : PRINT "正解！"
  IF CLEARED THEN
    LOCATE 9, 11 : PRINT "地上への階段だ..."
  ELSE
    LOCATE 9, 11 : PRINT "正しい道を進んでいる"
    LOCATE 7, 13 : COLOR #888888
    IF FLOOR > 1 THEN
      PRINT "現在地: B"; FLOOR; "F"
    ELSE
      PRINT "もうすぐ地上だ..."
    ENDIF
  ENDIF
ELSE
  GFILL 60, 60, 260, 170, #441A1A
  GBOX 60, 60, 260, 170, #FF4444
  LOCATE 13, 9 : COLOR #FF4444 : PRINT "判断ミス"
  IF HAS_ANOMALY THEN
    LOCATE 6, 11 : PRINT "異変があった..."
    LOCATE 6, 12 : PRINT "戻るべきだった"
  ELSE
    LOCATE 6, 11 : PRINT "異変はなかった..."
    LOCATE 6, 12 : PRINT "進むべきだった"
  ENDIF
  LOCATE 10, 14 : PRINT "MISS: "; MISTAKES; " / 3"
ENDIF

LOCATE 9, 18 : COLOR #888888 : PRINT "Aボタンで次へ"
COLOR #FFFFFF
RETURN

' ===== クリア =====
@DRAW_CLEAR
GFILL 30, 30, 290, 210, #1A1A44
GBOX 30, 30, 290, 210, #FFFF88

LOCATE 10, 5 : COLOR #FFFF88 : PRINT "【 脱 出 成 功 】"

LOCATE 5, 8 : COLOR #6666FF
PRINT "階段を上ると、そこは..."
LOCATE 5, 9
PRINT "見慣れた新宿駅の改札だった。"
LOCATE 5, 11
PRINT "夜明けの光が窓から差し込んでいる。"
LOCATE 5, 12
PRINT "始発電車のアナウンスが聞こえる。"
LOCATE 5, 14
PRINT "あの地下は...本当に存在したのか？"
LOCATE 5, 15
PRINT "今となっては、わからない。"

LOCATE 8, 18 : COLOR #FFFFFF : PRINT "MISTAKES: "; MISTAKES
LOCATE 8, 19 : PRINT "STRESS: "; STRESS

IF MISTAKES == 0 AND STRESS < 5 THEN
  LOCATE 8, 21 : COLOR #FFFF00 : PRINT "★ PERFECT CLEAR ★"
ELSEIF MISTAKES <= 1 THEN
  LOCATE 10, 21 : COLOR #00FF00 : PRINT "RANK: S"
ELSEIF MISTAKES == 2 THEN
  LOCATE 10, 21 : COLOR #00FFFF : PRINT "RANK: A"
ELSE
  LOCATE 10, 21 : COLOR #FFFFFF : PRINT "RANK: B"
ENDIF

LOCATE 8, 24 : COLOR #888888 : PRINT "Aボタンでタイトルへ"
COLOR #FFFFFF
RETURN

' ===== ゲームオーバー =====
@DRAW_GAMEOVER
GFILL 30, 40, 290, 200, #2A1010
GBOX 30, 40, 290, 200, #FF0000

LOCATE 10, 6 : COLOR #FF0000 : PRINT "【 GAME OVER 】"

LOCATE 4, 9 : COLOR #888888
PRINT "地下深くへ迷い込んでしまった..."
LOCATE 4, 10
PRINT "もう地上への道はわからない。"
LOCATE 4, 12
PRINT "終わらない夜。終わらない地下。"
LOCATE 4, 13
PRINT "新宿ダンジョンは君を離さない。"

LOCATE 7, 16 : COLOR #FFFFFF
PRINT "到達: B"; FLOOR; "F"
LOCATE 7, 17
PRINT "進捗: "; STAGE; " / "; STAGE_COUNT

LOCATE 8, 22 : COLOR #888888 : PRINT "Aボタンでタイトルへ"
COLOR #FFFFFF
RETURN
