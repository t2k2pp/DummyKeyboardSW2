' ================================
' 富士樹海 【完全版】 (FUJI JUKAI)
' 8番出口風・観察型脱出ゲーム
' プチコン4用サンプルプログラム
' ================================
' プレイ時間: 約30分
' ステージ数: 20
' 異変パターン: 15種類
' ================================

OPTION STRICT
ACLS

' 定数
CONST STAGE_COUNT = 20
CONST TEXT_SPEED = 2
CONST MAX_ANOMALY_TYPES = 15

' 変数
DIM STAGE, MISTAKES, CLEARED
DIM TEXT$[20], LINE_COUNT
DIM HAS_ANOMALY, ANOMALY_TYPE
DIM CHOICE, TYPING_LINE, TYPING_POS
DIM GAME_STATE
DIM AREA  ' 0=入口, 1=森, 2=沼, 3=洞窟, 4=出口付近
DIM TIME_OF_DAY  ' 0=夜, 1=夜明け前, 2=朝
DIM SANITY  ' 正気度
DIM FOUND_ITEMS[5]  ' 発見アイテム

' 各ステージの異変情報
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
AREA = 0
TIME_OF_DAY = 0
SANITY = 100

FOR I = 0 TO 4
  FOUND_ITEMS[I] = 0
NEXT

FOR I = 0 TO STAGE_COUNT - 1
  STAGE_ANOMALY[I] = RND(2)
NEXT
RETURN

' ===== ステージ開始 =====
@START_STAGE
TYPING_LINE = 0
TYPING_POS = 0
CHOICE = 0

' エリア更新
IF STAGE < 4 THEN
  AREA = 0
ELSEIF STAGE < 8 THEN
  AREA = 1
ELSEIF STAGE < 12 THEN
  AREA = 2
ELSEIF STAGE < 16 THEN
  AREA = 3
ELSE
  AREA = 4
ENDIF

' 時間帯更新
IF STAGE < 7 THEN
  TIME_OF_DAY = 0
ELSEIF STAGE < 14 THEN
  TIME_OF_DAY = 1
ELSE
  TIME_OF_DAY = 2
ENDIF

HAS_ANOMALY = STAGE_ANOMALY[STAGE]
ANOMALY_TYPE = RND(MAX_ANOMALY_TYPES)

GOSUB @GENERATE_SCENE
RETURN

' ===== シーン生成 =====
@GENERATE_SCENE
LINE_COUNT = 0

' エリア別の基本描写
ON AREA GOSUB @DESC_ENTRANCE, @DESC_FOREST, @DESC_SWAMP, @DESC_CAVE, @DESC_EXIT

' 時間帯の描写追加
GOSUB @DESC_TIME

' 異変の有無で追加描写
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

' ===== 入口エリア =====
@DESC_ENTRANCE
TEXT$[0] = "　深い樹海の入り口付近を歩いている。"
TEXT$[1] = ""
VAR N = STAGE MOD 4
IF N == 0 THEN
  TEXT$[2] = "　鬱蒼と茂る木々が、空を覆い隠している。"
  TEXT$[3] = "　地面には苔と落ち葉が厚く積もっている。"
ELSEIF N == 1 THEN
  TEXT$[2] = "　倒木が道を塞いでいる。"
  TEXT$[3] = "　迂回して進むしかない。"
ELSEIF N == 2 THEN
  TEXT$[2] = "　古い看板が立っている。"
  TEXT$[3] = "　『この先、危険区域』と読める。"
ELSE
  TEXT$[2] = "　木の根が複雑に絡み合っている。"
  TEXT$[3] = "　足を取られないよう、慎重に進む。"
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 森エリア =====
@DESC_FOREST
TEXT$[0] = "　深い森の中を歩いている。"
TEXT$[1] = ""
VAR N = STAGE MOD 4
IF N == 0 THEN
  TEXT$[2] = "　木々の密度がさらに増してきた。"
  TEXT$[3] = "　どこを見ても同じ景色に見える。"
ELSEIF N == 1 THEN
  TEXT$[2] = "　木の幹に赤いリボンが結ばれている。"
  TEXT$[3] = "　おそらく登山者の目印だろう。"
  FOUND_ITEMS[0] = 1
ELSEIF N == 2 THEN
  TEXT$[2] = "　巨大な岩が転がっている。"
  TEXT$[3] = "　苔に覆われ、長い年月を感じさせる。"
ELSE
  TEXT$[2] = "　獣道のような細い道が続いている。"
  TEXT$[3] = "　動物の足跡が残っている。"
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 沼地エリア =====
@DESC_SWAMP
TEXT$[0] = "　足元がぬかるんでいる沼地に出た。"
TEXT$[1] = ""
VAR N = STAGE MOD 4
IF N == 0 THEN
  TEXT$[2] = "　濃い霧が立ち込めている。"
  TEXT$[3] = "　数メートル先も見えない。"
ELSEIF N == 1 THEN
  TEXT$[2] = "　枯れた木々が水面から突き出ている。"
  TEXT$[3] = "　不気味な風景が広がる。"
ELSEIF N == 2 THEN
  TEXT$[2] = "　水面に何かが浮いている。"
  TEXT$[3] = "　古い衣服のようだ..."
  DEC SANITY
ELSE
  TEXT$[2] = "　蛙の鳴き声が響いている。"
  TEXT$[3] = "　生き物の気配に少し安心する。"
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 洞窟エリア =====
@DESC_CAVE
TEXT$[0] = "　岩場が多くなり、洞窟を発見した。"
TEXT$[1] = ""
VAR N = STAGE MOD 4
IF N == 0 THEN
  TEXT$[2] = "　洞窟の入り口は暗く、深そうだ。"
  TEXT$[3] = "　中から冷たい風が吹いてくる。"
ELSEIF N == 1 THEN
  TEXT$[2] = "　洞窟の壁に何か刻まれている。"
  TEXT$[3] = "　古い文字のようだが、読めない。"
  FOUND_ITEMS[1] = 1
ELSEIF N == 2 THEN
  TEXT$[2] = "　洞窟の奥から水の音が聞こえる。"
  TEXT$[3] = "　地下水脈があるのかもしれない。"
ELSE
  TEXT$[2] = "　洞窟を抜けると、また森に出た。"
  TEXT$[3] = "　少し開けた場所のようだ。"
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 出口付近エリア =====
@DESC_EXIT
TEXT$[0] = "　木々の間から光が見える。"
TEXT$[1] = ""
VAR N = STAGE MOD 4
IF N == 0 THEN
  TEXT$[2] = "　出口が近いのかもしれない。"
  TEXT$[3] = "　足取りが自然と速くなる。"
ELSEIF N == 1 THEN
  TEXT$[2] = "　遠くに車の音が聞こえた気がする。"
  TEXT$[3] = "　道路が近いのだろうか。"
ELSEIF N == 2 THEN
  TEXT$[2] = "　携帯電話を確認する。"
  TEXT$[3] = "　まだ圏外だが、希望が見えてきた。"
ELSE
  TEXT$[2] = "　木々の密度が減ってきた。"
  TEXT$[3] = "　確実に出口に近づいている。"
ENDIF
TEXT$[4] = ""
LINE_COUNT = 5
RETURN

' ===== 時間帯描写 =====
@DESC_TIME
VAR L = LINE_COUNT
IF TIME_OF_DAY == 0 THEN
  TEXT$[L] = "　まだ深夜だ。月明かりだけが頼り。"
ELSEIF TIME_OF_DAY == 1 THEN
  TEXT$[L] = "　空がうっすらと白み始めている。"
ELSE
  TEXT$[L] = "　朝日が木々の間から差し込んでいる。"
ENDIF
TEXT$[L + 1] = ""
LINE_COUNT = L + 2
RETURN

' ===== 正常時 =====
@ADD_NORMAL
VAR L = LINE_COUNT
VAR N = RND(6)
IF N == 0 THEN
  TEXT$[L] = "　静寂の中、風が木々を揺らしている。"
  TEXT$[L + 1] = "　遠くで鳥の鳴き声が聞こえる。"
ELSEIF N == 1 THEN
  TEXT$[L] = "　足元には落ち葉が積もっている。"
  TEXT$[L + 1] = "　踏みしめると乾いた音がする。"
ELSEIF N == 2 THEN
  TEXT$[L] = "　空気が澄んでいて、深呼吸する。"
  TEXT$[L + 1] = "　自然の匂いが心を落ち着かせる。"
ELSEIF N == 3 THEN
  TEXT$[L] = "　コンパスを確認する。"
  TEXT$[L + 1] = "　北を指している。正常だ。"
ELSEIF N == 4 THEN
  TEXT$[L] = "　地面に動物の足跡がある。"
  TEXT$[L + 1] = "　鹿だろうか。自然のままの森だ。"
ELSE
  TEXT$[L] = "　木々の配置に規則性はない。"
  TEXT$[L + 1] = "　自然に育った森のようだ。"
ENDIF
TEXT$[L + 2] = ""
TEXT$[L + 3] = "　特に変わった様子はない。"
LINE_COUNT = L + 4
RETURN

' ===== 異変時 =====
@ADD_ANOMALY
VAR L = LINE_COUNT
DEC SANITY

IF ANOMALY_TYPE == 0 THEN
  TEXT$[L] = "　ふと気づくと、同じ木が何本も"
  TEXT$[L + 1] = "　規則正しく並んでいる。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...自然の森ではありえない配置だ。"
ELSEIF ANOMALY_TYPE == 1 THEN
  TEXT$[L] = "　空を見上げると、太陽が二つ見える。"
  TEXT$[L + 1] = "　いや、あれは本当に太陽か？"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...何かがおかしい。"
ELSEIF ANOMALY_TYPE == 2 THEN
  TEXT$[L] = "　足元に靴が片方だけ落ちている。"
  TEXT$[L + 1] = "　それは...自分が履いている靴と同じだ。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...これは何かの警告か？"
ELSEIF ANOMALY_TYPE == 3 THEN
  TEXT$[L] = "　木の幹に「モドレ」と刻まれている。"
  TEXT$[L + 1] = "　まだ新しい傷跡だ。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...誰がこれを？"
ELSEIF ANOMALY_TYPE == 4 THEN
  TEXT$[L] = "　遠くに人影が見える。"
  TEXT$[L + 1] = "　しかし、その人影には顔がない。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...近づいてはいけない気がする。"
ELSEIF ANOMALY_TYPE == 5 THEN
  TEXT$[L] = "　コンパスを確認する。"
  TEXT$[L + 1] = "　針がぐるぐると回り続けている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...磁場が狂っている？"
ELSEIF ANOMALY_TYPE == 6 THEN
  TEXT$[L] = "　さっき通った場所に戻ってきた気がする。"
  TEXT$[L + 1] = "　同じ岩、同じ木...いや、違う。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　岩の位置が微妙にずれている。"
ELSEIF ANOMALY_TYPE == 7 THEN
  TEXT$[L] = "　木の根元に人形が置いてある。"
  TEXT$[L + 1] = "　藁で作られた人形だ。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　目の部分に釘が刺さっている..."
ELSEIF ANOMALY_TYPE == 8 THEN
  TEXT$[L] = "　足音が聞こえる。"
  TEXT$[L + 1] = "　自分の足音ではない。後ろからだ。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　振り返っても誰もいないのに..."
ELSEIF ANOMALY_TYPE == 9 THEN
  TEXT$[L] = "　木々の間に、白い着物の女性が立っている。"
  TEXT$[L + 1] = "　こちらをじっと見ている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...瞬きをしたら消えていた。"
ELSEIF ANOMALY_TYPE == 10 THEN
  TEXT$[L] = "　空から血のような赤い雨が降っている。"
  TEXT$[L + 1] = "　手を見ると、赤く染まっている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...いや、幻覚だ。そうに違いない。"
ELSEIF ANOMALY_TYPE == 11 THEN
  TEXT$[L] = "　木々が一斉にこちらを向いた気がした。"
  TEXT$[L + 1] = "　枝がまるで手のように伸びている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...疲れているのだろうか。"
ELSEIF ANOMALY_TYPE == 12 THEN
  TEXT$[L] = "　足元の影が、自分と違う動きをしている。"
  TEXT$[L + 1] = "　こちらを見上げている..."
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...絶対に見てはいけない。"
ELSEIF ANOMALY_TYPE == 13 THEN
  TEXT$[L] = "　携帯電話が突然光った。"
  TEXT$[L + 1] = "　画面には「帰レ」とだけ表示されている。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...圏外のはずなのに。"
ELSE
  TEXT$[L] = "　地面に無数の手形がついている。"
  TEXT$[L + 1] = "　どれも同じ大きさ、同じ形。"
  TEXT$[L + 2] = ""
  TEXT$[L + 3] = "　...まるで引きずり込まれたかのよう。"
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
' 背景色（時間帯とエリアで変化）
VAR BG
IF TIME_OF_DAY == 0 THEN
  BG = #000811
ELSEIF TIME_OF_DAY == 1 THEN
  BG = #0A1122
ELSE
  BG = #112211
ENDIF
IF AREA == 2 THEN BG = BG + #000808
IF AREA == 3 THEN BG = BG - #040404
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
GFILL 50, 30, 270, 110, #002200
GBOX 50, 30, 270, 110, #00FF00

LOCATE 12, 5 : COLOR #00FF00 : PRINT "富 士 樹 海"
LOCATE 10, 7 : COLOR #008800 : PRINT "【 完 全 版 】"
LOCATE 9, 9 : COLOR #006600 : PRINT "～ 脱出への長い道 ～"

LOCATE 2, 13 : COLOR #888888
PRINT "気がつけば、深い樹海の中にいた。"
LOCATE 2, 14
PRINT "どこまでも続く木々と闇。"
LOCATE 2, 15
PRINT "正気を保ち、20のステージを超えて脱出せよ。"

LOCATE 4, 18 : COLOR #FFFF00 : PRINT "【ルール】"
LOCATE 4, 19 : COLOR #AAAAAA : PRINT "異変を見つけたら → 引き返す"
LOCATE 4, 20 : PRINT "異変がなければ → 先へ進む"
LOCATE 4, 21 : PRINT "3回のミスでゲームオーバー"

LOCATE 9, 25 : COLOR #00FF00 : PRINT "Aボタンでスタート"

COLOR #FFFFFF
RETURN

' ===== ゲーム =====
@DRAW_GAME
' ステータスバー
VAR AREA_NAME$
IF AREA == 0 THEN AREA_NAME$ = "入口付近"
IF AREA == 1 THEN AREA_NAME$ = "深い森"
IF AREA == 2 THEN AREA_NAME$ = "霧の沼地"
IF AREA == 3 THEN AREA_NAME$ = "岩場・洞窟"
IF AREA == 4 THEN AREA_NAME$ = "出口付近"

LOCATE 0, 0 : COLOR #008800
PRINT AREA_NAME$; " ["; STAGE + 1; "/"; STAGE_COUNT; "]"
LOCATE 26, 0 : PRINT "MISS:"; MISTAKES; "/3"

' 正気度ゲージ
GFILL 260, 15, 310, 22, #333333
GFILL 260, 15, 260 + SANITY / 2, 22, #00FF00
IF SANITY < 50 THEN GFILL 260, 15, 260 + SANITY / 2, 22, #FFFF00
IF SANITY < 25 THEN GFILL 260, 15, 260 + SANITY / 2, 22, #FF0000

' テキストウィンドウ
GFILL 5, 35, 315, 200, #001100
GBOX 5, 35, 315, 200, #004400

' テキスト表示
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
    COLOR #88FF88
  ENDIF
  
  IF I == TYPING_LINE AND TYPING_LINE < LINE_COUNT - 4 THEN
    VAR SHOW_LEN = TYPING_POS / TEXT_SPEED
    TXT$ = LEFT$(TXT$, SHOW_LEN)
  ENDIF
  
  LOCATE 1, 5 + I : PRINT TXT$
NEXT

' 進行度バー
GFILL 10, 220, 310, 230, #003300
GFILL 10, 220, 10 + 300 * STAGE / STAGE_COUNT, 230, #00FF00
GBOX 10, 220, 310, 230, #006600

COLOR #FFFFFF
RETURN

' ===== 結果 =====
@DRAW_RESULT
VAR CORRECT = FALSE
IF HAS_ANOMALY AND CHOICE == 1 THEN CORRECT = TRUE
IF NOT HAS_ANOMALY AND CHOICE == 0 THEN CORRECT = TRUE

IF CORRECT THEN
  GFILL 70, 70, 250, 170, #003300
  GBOX 70, 70, 250, 170, #00FF00
  LOCATE 14, 10 : COLOR #00FF00 : PRINT "正解！"
  IF CLEARED THEN
    LOCATE 9, 12 : PRINT "出口が見えてきた..."
  ELSE
    LOCATE 9, 12 : PRINT "正しい道を進んでいる"
    LOCATE 9, 14 : COLOR #888888
    PRINT "残り "; STAGE_COUNT - STAGE; " ステージ"
  ENDIF
ELSE
  GFILL 70, 70, 250, 170, #330000
  GBOX 70, 70, 250, 170, #FF0000
  LOCATE 13, 10 : COLOR #FF0000 : PRINT "判断ミス"
  IF HAS_ANOMALY THEN
    LOCATE 6, 12 : PRINT "異変があった..."
    LOCATE 6, 13 : PRINT "戻るべきだった"
  ELSE
    LOCATE 6, 12 : PRINT "異変はなかった..."
    LOCATE 6, 13 : PRINT "進むべきだった"
  ENDIF
  LOCATE 10, 15 : PRINT "MISS: "; MISTAKES; " / 3"
ENDIF

LOCATE 9, 19 : COLOR #888888 : PRINT "Aボタンで次へ"
COLOR #FFFFFF
RETURN

' ===== クリア =====
@DRAW_CLEAR
GFILL 40, 40, 280, 200, #003300
GBOX 40, 40, 280, 200, #00FF00

LOCATE 10, 6 : COLOR #FFFF00 : PRINT "【 脱 出 成 功 】"

LOCATE 6, 9 : COLOR #00FF00
PRINT "木々の間から差し込む朝日。"
LOCATE 6, 10
PRINT "遠くに車の音が聞こえる。"
LOCATE 6, 12
PRINT "ついに...樹海から脱出した。"
LOCATE 6, 13
PRINT "長い夜が終わった。"

LOCATE 8, 16 : COLOR #FFFFFF : PRINT "MISTAKES: "; MISTAKES
LOCATE 8, 17 : PRINT "SANITY: "; SANITY; "%"

IF MISTAKES == 0 AND SANITY >= 80 THEN
  LOCATE 8, 19 : COLOR #FFFF00 : PRINT "★ PERFECT CLEAR ★"
ELSEIF MISTAKES <= 1 THEN
  LOCATE 10, 19 : COLOR #00FF00 : PRINT "RANK: S"
ELSEIF MISTAKES == 2 THEN
  LOCATE 10, 19 : COLOR #00FFFF : PRINT "RANK: A"
ELSE
  LOCATE 10, 19 : COLOR #FFFFFF : PRINT "RANK: B"
ENDIF

LOCATE 8, 23 : COLOR #888888 : PRINT "Aボタンでタイトルへ"
COLOR #FFFFFF
RETURN

' ===== ゲームオーバー =====
@DRAW_GAMEOVER
GFILL 40, 50, 280, 190, #220000
GBOX 40, 50, 280, 190, #FF0000

LOCATE 10, 8 : COLOR #FF0000 : PRINT "【 GAME OVER 】"

LOCATE 5, 11 : COLOR #888888
PRINT "森の奥深くへ迷い込んでしまった..."
LOCATE 5, 12
PRINT "もう戻る道はわからない。"
LOCATE 5, 14
PRINT "樹海は、新たな住人を得た。"

LOCATE 7, 17 : COLOR #FFFFFF
PRINT "到達: "; STAGE; " / "; STAGE_COUNT; " ステージ"

LOCATE 8, 21 : COLOR #888888 : PRINT "Aボタンでタイトルへ"
COLOR #FFFFFF
RETURN
