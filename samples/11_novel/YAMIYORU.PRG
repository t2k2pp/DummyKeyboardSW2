' ================================
' 闇夜の館 (YAMIYORU)
' マルチエンディング型サウンドノベル
' プチコン4用サンプルプログラム
' ================================
' 操作方法:
'   Aボタン: 次へ進む/選択決定
'   十字キー上下: 選択肢を選ぶ
' ================================
' 弟切草を彷彿させる
' ホラー系サウンドノベル
' 5種類のエンディングあり
' ================================

OPTION STRICT
ACLS

' 定数
CONST TEXT_SPEED = 2  ' テキスト表示速度

' 変数宣言
DIM SCENE, CHOICE, MAX_CHOICE
DIM TEXT$[20], LINE_COUNT
DIM TYPING_POS, TYPING_LINE
DIM WAIT_INPUT
DIM FLAGS[10]  ' フラグ管理
DIM ENDING

' 初期化
GOSUB @INIT_GAME

' メインループ
LOOP
  VSYNC
  GOSUB @UPDATE
  GOSUB @DRAW
ENDLOOP

' ===== 初期化 =====
@INIT_GAME
ACLS
SCENE = 0
CHOICE = 0
MAX_CHOICE = 0
ENDING = 0
FOR I = 0 TO 9
  FLAGS[I] = 0
NEXT
GOSUB @LOAD_SCENE
RETURN

' ===== シーン読み込み =====
@LOAD_SCENE
LINE_COUNT = 0
TYPING_POS = 0
TYPING_LINE = 0
WAIT_INPUT = FALSE
CHOICE = 0
MAX_CHOICE = 0

' 各シーンのテキストを設定
IF SCENE == 0 THEN GOSUB @SCENE_TITLE
IF SCENE == 1 THEN GOSUB @SCENE_PROLOGUE
IF SCENE == 2 THEN GOSUB @SCENE_ENTRANCE
IF SCENE == 3 THEN GOSUB @SCENE_HALL
IF SCENE == 4 THEN GOSUB @SCENE_UPSTAIRS
IF SCENE == 5 THEN GOSUB @SCENE_BASEMENT
IF SCENE == 6 THEN GOSUB @SCENE_LIBRARY
IF SCENE == 7 THEN GOSUB @SCENE_SECRET
IF SCENE == 8 THEN GOSUB @SCENE_FINAL
IF SCENE >= 100 THEN GOSUB @SCENE_ENDING
RETURN

' ===== タイトル =====
@SCENE_TITLE
TEXT$[0] = ""
TEXT$[1] = ""
TEXT$[2] = "　　　　闇　夜　の　館"
TEXT$[3] = ""
TEXT$[4] = "　　～ サウンドノベル ～"
TEXT$[5] = ""
TEXT$[6] = ""
TEXT$[7] = "　　　Aボタンでスタート"
LINE_COUNT = 8
RETURN

' ===== プロローグ =====
@SCENE_PROLOGUE
TEXT$[0] = "　深夜——"
TEXT$[1] = ""
TEXT$[2] = "　車が故障し、私は山道で立ち往生していた。"
TEXT$[3] = "　携帯の電波も届かない。"
TEXT$[4] = ""
TEXT$[5] = "　ふと見上げると、闇の中に"
TEXT$[6] = "　古びた洋館がぼんやりと浮かんでいた。"
TEXT$[7] = ""
TEXT$[8] = "　助けを求めるため、私は重い足取りで"
TEXT$[9] = "　その館へと向かった..."
LINE_COUNT = 10
RETURN

' ===== 玄関 =====
@SCENE_ENTRANCE
TEXT$[0] = "　館の玄関に立つ。"
TEXT$[1] = ""
TEXT$[2] = "　錆びた門扉は、まるで招き入れるように"
TEXT$[3] = "　わずかに開いていた。"
TEXT$[4] = ""
TEXT$[5] = "　中からは何も聞こえない。"
TEXT$[6] = "　しかし、どこからか視線を感じる..."
TEXT$[7] = ""
TEXT$[8] = "【どうする？】"
TEXT$[9] = "　▶ 声をかけてから入る"
TEXT$[10] = "　　 黙って中に入る"
LINE_COUNT = 11
MAX_CHOICE = 2
RETURN

' ===== ホール =====
@SCENE_HALL
IF FLAGS[0] == 1 THEN
  TEXT$[0] = "　「ごめんください...」"
  TEXT$[1] = ""
  TEXT$[2] = "　声をかけたが、返事はない。"
  TEXT$[3] = "　しかし、奥でかすかに物音がした。"
  TEXT$[4] = "　誰かいるのかもしれない。"
ELSE
  TEXT$[0] = "　音を立てずに中に入る。"
  TEXT$[1] = ""
  TEXT$[2] = "　ホールは薄暗く、埃っぽい匂いがする。"
  TEXT$[3] = "　長い間、誰も住んでいないようだ。"
  TEXT$[4] = "　壁には古い肖像画がかかっている。"
ENDIF
TEXT$[5] = ""
TEXT$[6] = "　正面には二階へ続く階段。"
TEXT$[7] = "　左手には地下へ続く扉がある。"
TEXT$[8] = ""
TEXT$[9] = "【どちらへ向かう？】"
TEXT$[10] = "　▶ 二階へ上がる"
TEXT$[11] = "　　 地下へ降りる"
LINE_COUNT = 12
MAX_CHOICE = 2
RETURN

' ===== 二階 =====
@SCENE_UPSTAIRS
TEXT$[0] = "　軋む階段を上り、二階へ。"
TEXT$[1] = ""
TEXT$[2] = "　廊下には複数の部屋がある。"
TEXT$[3] = "　一番奥の部屋から、"
TEXT$[4] = "　薄明かりが漏れているのが見えた。"
TEXT$[5] = ""
TEXT$[6] = "　その時、背後で何かが動く気配がした。"
TEXT$[7] = "　振り返ると———誰もいない。"
TEXT$[8] = ""
TEXT$[9] = "【どうする？】"
TEXT$[10] = "　▶ 明かりの漏れる部屋へ"
TEXT$[11] = "　　 階段を降りて逃げる"
LINE_COUNT = 12
MAX_CHOICE = 2
RETURN

' ===== 地下 =====
@SCENE_BASEMENT
TEXT$[0] = "　地下への階段は暗く、冷たい。"
TEXT$[1] = ""
TEXT$[2] = "　壁に沿って、かすかな明かりが"
TEXT$[3] = "　揺らめいている。"
TEXT$[4] = ""
TEXT$[5] = "　突き当たりには錆びた鉄の扉。"
TEXT$[6] = "　扉の向こうから、かすかに"
TEXT$[7] = "　すすり泣くような声が聞こえる..."
TEXT$[8] = ""
TEXT$[9] = "【どうする？】"
TEXT$[10] = "　▶ 扉を開ける"
TEXT$[11] = "　　 引き返す"
LINE_COUNT = 12
MAX_CHOICE = 2
RETURN

' ===== 書斎 =====
@SCENE_LIBRARY
TEXT$[0] = "　明かりの部屋は書斎だった。"
TEXT$[1] = ""
TEXT$[2] = "　机の上には開かれた日記。"
TEXT$[3] = "　最後のページにはこう書かれていた。"
TEXT$[4] = ""
TEXT$[5] = "　「彼女は地下にいる。"
TEXT$[6] = "　　決して扉を開けてはならない。」"
TEXT$[7] = ""
TEXT$[8] = "　本棚の裏に隠し通路を発見した。"
TEXT$[9] = ""
TEXT$[10] = "【どうする？】"
TEXT$[11] = "　▶ 隠し通路へ入る"
TEXT$[12] = "　　 地下へ向かう"
LINE_COUNT = 13
MAX_CHOICE = 2
FLAGS[1] = 1  ' 日記を読んだフラグ
RETURN

' ===== 隠し通路 =====
@SCENE_SECRET
TEXT$[0] = "　隠し通路を進むと、"
TEXT$[1] = "　小さな祭壇のある部屋に出た。"
TEXT$[2] = ""
TEXT$[3] = "　祭壇には古い写真と、"
TEXT$[4] = "　錆びた鍵が置かれていた。"
TEXT$[5] = ""
TEXT$[6] = "　写真には若い女性が写っている。"
TEXT$[7] = "　目元だけが黒く塗りつぶされて..."
TEXT$[8] = ""
TEXT$[9] = "【鍵を取るか？】"
TEXT$[10] = "　▶ 鍵を取る"
TEXT$[11] = "　　 何も触らずに出る"
LINE_COUNT = 12
MAX_CHOICE = 2
RETURN

' ===== 最終選択 =====
@SCENE_FINAL
IF FLAGS[2] == 1 THEN
  TEXT$[0] = "　鍵を手に、地下の扉の前に立つ。"
ELSE
  TEXT$[0] = "　地下の扉の前に戻ってきた。"
ENDIF
TEXT$[1] = ""
TEXT$[2] = "　扉の向こうから、また声がする。"
TEXT$[3] = ""
TEXT$[4] = "　「...助けて...」"
TEXT$[5] = ""
IF FLAGS[1] == 1 THEN
  TEXT$[6] = "　日記の言葉が頭をよぎる。"
  TEXT$[7] = "　「決して開けてはならない」"
ELSE
  TEXT$[6] = "　誰かが閉じ込められている？"
  TEXT$[7] = "　助けなければ..."
ENDIF
TEXT$[8] = ""
TEXT$[9] = "【最後の選択】"
TEXT$[10] = "　▶ 扉を開ける"
TEXT$[11] = "　　 館を出る"
LINE_COUNT = 12
MAX_CHOICE = 2
RETURN

' ===== エンディング =====
@SCENE_ENDING
IF ENDING == 1 THEN
  ' TRUE END - 全ての条件を満たして脱出
  TEXT$[0] = "　私は扉を開けずに館を出た。"
  TEXT$[1] = ""
  TEXT$[2] = "　夜明けと共に、助けが来た。"
  TEXT$[3] = ""
  TEXT$[4] = "　後日調べると、あの館では"
  TEXT$[5] = "　百年前に悲劇があったという。"
  TEXT$[6] = ""
  TEXT$[7] = "　私は——正しい選択をしたのだ。"
  TEXT$[8] = ""
  TEXT$[9] = "　　　【 TRUE END 】"
  TEXT$[10] = "　　　～生還者～"
  LINE_COUNT = 11
ELSEIF ENDING == 2 THEN
  ' GOOD END - 日記を読んで逃げた
  TEXT$[0] = "　扉を開けた瞬間——"
  TEXT$[1] = ""
  TEXT$[2] = "　闇の中から白い手が伸びてきた。"
  TEXT$[3] = ""
  TEXT$[4] = "　しかし鍵が光を放ち、"
  TEXT$[5] = "　その手は消えていった。"
  TEXT$[6] = ""
  TEXT$[7] = "　部屋の中には...誰もいなかった。"
  TEXT$[8] = ""
  TEXT$[9] = "　　　【 GOOD END 】"
  TEXT$[10] = "　　　～封印の鍵～"
  LINE_COUNT = 11
ELSEIF ENDING == 3 THEN
  ' NORMAL END - 普通に脱出
  TEXT$[0] = "　私は急いで館を出た。"
  TEXT$[1] = ""
  TEXT$[2] = "　振り返ると、二階の窓から"
  TEXT$[3] = "　誰かがこちらを見ていた。"
  TEXT$[4] = ""
  TEXT$[5] = "　あれは...誰だったのだろう。"
  TEXT$[6] = ""
  TEXT$[7] = "　　　【 NORMAL END 】"
  TEXT$[8] = "　　　～夜明け前～"
  LINE_COUNT = 9
ELSEIF ENDING == 4 THEN
  ' BAD END - 扉を開けてしまった
  TEXT$[0] = "　扉を開けた。"
  TEXT$[1] = ""
  TEXT$[2] = "　暗闇の中に、白い顔が浮かんでいた。"
  TEXT$[3] = ""
  TEXT$[4] = "　「待ってたの...」"
  TEXT$[5] = ""
  TEXT$[6] = "　私の意識は、そこで途切れた——"
  TEXT$[7] = ""
  TEXT$[8] = "　　　【 BAD END 】"
  TEXT$[9] = "　　　～闇に囚われし者～"
  LINE_COUNT = 10
ELSE
  ' DEAD END - 逃げようとして捕まった
  TEXT$[0] = "　階段を駆け下りる。"
  TEXT$[1] = ""
  TEXT$[2] = "　しかし、玄関の扉は開かない。"
  TEXT$[3] = ""
  TEXT$[4] = "　背後に、冷たい手の感触——"
  TEXT$[5] = ""
  TEXT$[6] = "　「逃がさない...」"
  TEXT$[7] = ""
  TEXT$[8] = "　　　【 DEAD END 】"
  TEXT$[9] = "　　　～館の住人～"
  LINE_COUNT = 10
ENDIF
TEXT$[LINE_COUNT] = ""
TEXT$[LINE_COUNT + 1] = "　Aボタンでタイトルへ"
LINE_COUNT = LINE_COUNT + 2
RETURN

' ===== 更新処理 =====
@UPDATE
VAR B = BUTTON(2)

' テキスト表示中
IF TYPING_LINE < LINE_COUNT THEN
  INC TYPING_POS
  IF TYPING_POS >= LEN(TEXT$[TYPING_LINE]) * TEXT_SPEED THEN
    TYPING_POS = 0
    INC TYPING_LINE
  ENDIF
  
  ' Aボタンでスキップ
  IF B AND 16 THEN
    TYPING_LINE = LINE_COUNT
  ENDIF
  RETURN
ENDIF

' 選択肢がある場合
IF MAX_CHOICE > 0 THEN
  IF B AND 1 THEN CHOICE = (CHOICE - 1 + MAX_CHOICE) MOD MAX_CHOICE
  IF B AND 2 THEN CHOICE = (CHOICE + 1) MOD MAX_CHOICE
  
  IF B AND 16 THEN
    GOSUB @PROCESS_CHOICE
    BEEP 0
  ENDIF
ELSE
  ' 選択肢がない場合、Aボタンで次へ
  IF B AND 16 THEN
    GOSUB @NEXT_SCENE
    BEEP 0
  ENDIF
ENDIF
RETURN

' ===== 選択処理 =====
@PROCESS_CHOICE
IF SCENE == 2 THEN
  ' 玄関：声をかける/黙って入る
  IF CHOICE == 0 THEN FLAGS[0] = 1  ' 声をかけた
  SCENE = 3  ' ホールへ
ELSEIF SCENE == 3 THEN
  ' ホール：二階/地下
  IF CHOICE == 0 THEN
    SCENE = 4  ' 二階へ
  ELSE
    SCENE = 5  ' 地下へ
  ENDIF
ELSEIF SCENE == 4 THEN
  ' 二階：明かりの部屋/逃げる
  IF CHOICE == 0 THEN
    SCENE = 6  ' 書斎へ
  ELSE
    ENDING = 5  ' DEAD END
    SCENE = 100
  ENDIF
ELSEIF SCENE == 5 THEN
  ' 地下：扉を開ける/引き返す
  IF CHOICE == 0 THEN
    ENDING = 4  ' BAD END
    SCENE = 100
  ELSE
    SCENE = 3  ' ホールへ戻る
  ENDIF
ELSEIF SCENE == 6 THEN
  ' 書斎：隠し通路/地下へ
  IF CHOICE == 0 THEN
    SCENE = 7  ' 隠し通路へ
  ELSE
    SCENE = 8  ' 最終選択へ
  ENDIF
ELSEIF SCENE == 7 THEN
  ' 隠し通路：鍵を取る/取らない
  IF CHOICE == 0 THEN FLAGS[2] = 1  ' 鍵を取った
  SCENE = 8  ' 最終選択へ
ELSEIF SCENE == 8 THEN
  ' 最終：扉を開ける/出る
  IF CHOICE == 0 THEN
    IF FLAGS[2] == 1 THEN
      ENDING = 2  ' GOOD END（鍵あり）
    ELSE
      ENDING = 4  ' BAD END
    ENDIF
  ELSE
    IF FLAGS[1] == 1 THEN
      ENDING = 1  ' TRUE END（日記読んだ）
    ELSE
      ENDING = 3  ' NORMAL END
    ENDIF
  ENDIF
  SCENE = 100
ENDIF

GOSUB @LOAD_SCENE
RETURN

' ===== 次のシーンへ =====
@NEXT_SCENE
IF SCENE == 0 THEN
  SCENE = 1  ' タイトル→プロローグ
ELSEIF SCENE == 1 THEN
  SCENE = 2  ' プロローグ→玄関
ELSEIF SCENE >= 100 THEN
  GOSUB @INIT_GAME  ' エンディング→タイトル
  RETURN
ENDIF
GOSUB @LOAD_SCENE
RETURN

' ===== 描画 =====
@DRAW
' 背景
IF SCENE >= 100 THEN
  GFILL 0, 0, 319, 239, #110000
ELSE
  GFILL 0, 0, 319, 239, #000011
ENDIF

' テキストウィンドウ
GFILL 10, 140, 310, 230, #000000
GBOX 10, 140, 310, 230, #444488

' テキスト表示
FOR I = 0 TO MIN(TYPING_LINE, LINE_COUNT - 1)
  VAR TXT$ = TEXT$[I]
  
  ' 選択肢のハイライト
  IF MAX_CHOICE > 0 AND I >= LINE_COUNT - MAX_CHOICE THEN
    VAR OPT_IDX = I - (LINE_COUNT - MAX_CHOICE)
    IF OPT_IDX == CHOICE THEN
      TXT$ = LEFT$(TXT$, 2) + "▶" + MID$(TXT$, 4)
      COLOR #FFFF00
    ELSE
      COLOR #888888
    ENDIF
  ELSE
    COLOR #FFFFFF
  ENDIF
  
  ' タイピング効果
  IF I == TYPING_LINE THEN
    VAR SHOW_LEN = TYPING_POS / TEXT_SPEED
    TXT$ = LEFT$(TXT$, SHOW_LEN)
  ENDIF
  
  LOCATE 2, 18 + I : PRINT TXT$
NEXT

' シーンタイトル（デバッグ用は消す）
' LOCATE 0, 0 : COLOR #444444 : PRINT "SCENE:"; SCENE

COLOR #FFFFFF
RETURN
