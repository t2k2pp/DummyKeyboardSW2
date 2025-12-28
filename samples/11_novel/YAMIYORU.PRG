' ================================
' 闇夜の館 【完全版】 (YAMIYORU)
' マルチエンディング型サウンドノベル
' プチコン4用サンプルプログラム
' ================================
' プレイ時間: 約30分
' エンディング: 7種類
' ================================

OPTION STRICT
ACLS

' 定数
CONST TEXT_SPEED = 2

' 変数
DIM SCENE, CHOICE, MAX_CHOICE
DIM TEXT$[30], LINE_COUNT
DIM TYPING_POS, TYPING_LINE
DIM FLAGS[20]
DIM ENDING
DIM TENSION  ' 緊張度（演出用）

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
SCENE = 0
CHOICE = 0
MAX_CHOICE = 0
ENDING = 0
TENSION = 0
FOR I = 0 TO 19
  FLAGS[I] = 0
NEXT
GOSUB @LOAD_SCENE
RETURN

' ===== シーン読み込み =====
@LOAD_SCENE
LINE_COUNT = 0
TYPING_POS = 0
TYPING_LINE = 0
CHOICE = 0
MAX_CHOICE = 0

ON SCENE GOSUB @S_TITLE, @S_PROLOGUE1, @S_PROLOGUE2, @S_PROLOGUE3
ON SCENE - 4 GOSUB @S_GATE, @S_ENTRANCE, @S_HALL1, @S_HALL2
ON SCENE - 8 GOSUB @S_STAIRS, @S_UPSTAIRS1, @S_UPSTAIRS2, @S_LIBRARY1
ON SCENE - 12 GOSUB @S_LIBRARY2, @S_SECRET1, @S_SECRET2, @S_BASEMENT1
ON SCENE - 16 GOSUB @S_BASEMENT2, @S_BASEMENT3, @S_RITUAL, @S_FINAL1
ON SCENE - 20 GOSUB @S_FINAL2, @S_ESCAPE1, @S_ESCAPE2

IF SCENE >= 100 THEN GOSUB @S_ENDING
RETURN

' ===== タイトル =====
@S_TITLE
TEXT$[0] = ""
TEXT$[1] = "　　　　　闇　夜　の　館"
TEXT$[2] = ""
TEXT$[3] = "　　　　【完全版】"
TEXT$[4] = ""
TEXT$[5] = "　　～ マルチエンディング ～"
TEXT$[6] = "　　　　サウンドノベル"
TEXT$[7] = ""
TEXT$[8] = ""
TEXT$[9] = "　　　　Aボタンでスタート"
LINE_COUNT = 10
RETURN

' ===== プロローグ1 =====
@S_PROLOGUE1
TEXT$[0] = "　深夜2時——"
TEXT$[1] = ""
TEXT$[2] = "　都心から離れた山道を、私は一人で"
TEXT$[3] = "　運転していた。"
TEXT$[4] = ""
TEXT$[5] = "　仕事が長引き、終電を逃したのだ。"
TEXT$[6] = "　車で帰るしかなかった。"
TEXT$[7] = ""
TEXT$[8] = "　ラジオからは深夜番組が流れている。"
TEXT$[9] = "　パーソナリティの声が、やけに"
TEXT$[10] = "　遠くに聞こえる。"
LINE_COUNT = 11
RETURN

' ===== プロローグ2 =====
@S_PROLOGUE2
TEXT$[0] = "　ふと、エンジンが異音を立てた。"
TEXT$[1] = ""
TEXT$[2] = "　「まさか...」"
TEXT$[3] = ""
TEXT$[4] = "　ダッシュボードの警告灯が点滅する。"
TEXT$[5] = "　車はゆっくりと速度を落とし、"
TEXT$[6] = "　やがて完全に停止した。"
TEXT$[7] = ""
TEXT$[8] = "　エンジンをかけ直すが、"
TEXT$[9] = "　うんともすんとも言わない。"
TEXT$[10] = ""
TEXT$[11] = "　携帯電話を取り出す。"
TEXT$[12] = "　——圏外。"
LINE_COUNT = 13
RETURN

' ===== プロローグ3 =====
@S_PROLOGUE3
TEXT$[0] = "　周囲は完全な闇に包まれていた。"
TEXT$[1] = ""
TEXT$[2] = "　街灯もなく、月明かりすら"
TEXT$[3] = "　厚い雲に遮られている。"
TEXT$[4] = ""
TEXT$[5] = "　ここで朝を待つか..."
TEXT$[6] = "　それとも、助けを求めに行くか..."
TEXT$[7] = ""
TEXT$[8] = "　その時、ふと視線を感じた。"
TEXT$[9] = ""
TEXT$[10] = "　山の上——"
TEXT$[11] = "　木々の間に、かすかな明かりが"
TEXT$[12] = "　見えた。建物がある。"
TEXT$[13] = ""
TEXT$[14] = "【どうする？】"
TEXT$[15] = "　▶ 車で朝を待つ"
TEXT$[16] = "　　 建物へ向かう"
LINE_COUNT = 17
MAX_CHOICE = 2
RETURN

' ===== 門前 =====
@S_GATE
TEXT$[0] = "　懐中電灯を持ち、建物へと向かった。"
TEXT$[1] = ""
TEXT$[2] = "　獣道のような細い道を15分ほど歩くと、"
TEXT$[3] = "　古びた洋館が姿を現した。"
TEXT$[4] = ""
TEXT$[5] = "　ヴィクトリア様式だろうか。"
TEXT$[6] = "　明治か大正時代に建てられたように見える。"
TEXT$[7] = ""
TEXT$[8] = "　錆びた鉄の門扉が、"
TEXT$[9] = "　まるで招き入れるように開いていた。"
TEXT$[10] = ""
TEXT$[11] = "　門には表札がある。"
TEXT$[12] = "　『黒澤邸』と読めた。"
TEXT$[13] = ""
TEXT$[14] = "　聞いたことのない名前だ。"
LINE_COUNT = 15
RETURN

' ===== 玄関 =====
@S_ENTRANCE
TEXT$[0] = "　玄関の扉の前に立つ。"
TEXT$[1] = ""
TEXT$[2] = "　重厚な木製の扉。"
TEXT$[3] = "　ノッカーには獅子の頭が彫られている。"
TEXT$[4] = ""
IF TENSION >= 3 THEN
  TEXT$[5] = "　獅子の目が、こちらを見ている気がした。"
  TEXT$[6] = "　...気のせいだろうか。"
ELSE
  TEXT$[5] = "　随分と立派な屋敷だ。"
  TEXT$[6] = "　まだ住人がいるのだろうか。"
ENDIF
TEXT$[7] = ""
TEXT$[8] = "【どうする？】"
TEXT$[9] = "　▶ ノックして声をかける"
TEXT$[10] = "　　 そっと扉を開けてみる"
LINE_COUNT = 11
MAX_CHOICE = 2
RETURN

' ===== ホール1 =====
@S_HALL1
IF FLAGS[0] == 1 THEN
  TEXT$[0] = "　「ごめんください...」"
  TEXT$[1] = ""
  TEXT$[2] = "　声をかけたが、返事はない。"
  TEXT$[3] = "　しかし、奥でかすかに物音がした。"
  TEXT$[4] = ""
  TEXT$[5] = "　誰かいるのかもしれない。"
  TEXT$[6] = "　意を決して中に入る。"
ELSE
  TEXT$[0] = "　そっと扉を押してみる。"
  TEXT$[1] = ""
  TEXT$[2] = "　鍵はかかっていなかった。"
  TEXT$[3] = "　軋む音を立てて、扉が開く。"
  TEXT$[4] = ""
  TEXT$[5] = "　不法侵入になるかもしれない。"
  TEXT$[6] = "　しかし、背に腹は代えられない。"
  INC TENSION
ENDIF
TEXT$[7] = ""
TEXT$[8] = "　中に入ると、広いホールが広がっていた。"
LINE_COUNT = 9
RETURN

' ===== ホール2 =====
@S_HALL2
TEXT$[0] = "　ホールは薄暗いが、"
TEXT$[1] = "　どこからか微かな明かりが差している。"
TEXT$[2] = ""
TEXT$[3] = "　床には厚い埃が積もっている。"
TEXT$[4] = "　長い間、人が来た形跡がない。"
TEXT$[5] = ""
TEXT$[6] = "　壁には古い肖像画が並んでいる。"
TEXT$[7] = "　どれも立派な身なりの人物だが..."
TEXT$[8] = "　なぜか全員、目元が黒く塗りつぶされていた。"
TEXT$[9] = ""
INC TENSION
TEXT$[10] = "　正面には二階へ続く大階段。"
TEXT$[11] = "　左手には地下へ続くらしき扉。"
TEXT$[12] = "　右手には別の廊下がある。"
TEXT$[13] = ""
TEXT$[14] = "【どこへ向かう？】"
TEXT$[15] = "　▶ 二階へ上がる"
TEXT$[16] = "　　 地下への扉を開ける"
TEXT$[17] = "　　 右の廊下を進む"
LINE_COUNT = 18
MAX_CHOICE = 3
RETURN

' ===== 階段 =====
@S_STAIRS
TEXT$[0] = "　大階段を上り始める。"
TEXT$[1] = ""
TEXT$[2] = "　一段一段、軋む音が響く。"
TEXT$[3] = "　この静寂の中では、"
TEXT$[4] = "　自分の足音さえも不気味に感じる。"
TEXT$[5] = ""
TEXT$[6] = "　階段の途中、後ろを振り返る。"
TEXT$[7] = ""
IF TENSION >= 5 THEN
  TEXT$[8] = "　一瞬、肖像画の一つが"
  TEXT$[9] = "　こちらを見ていた気がした。"
  TEXT$[10] = ""
  TEXT$[11] = "　...いや、気のせいだ。"
  TEXT$[12] = "　そう思い込むことにした。"
  LINE_COUNT = 13
ELSE
  TEXT$[8] = "　ホールが暗闘に沈んでいる。"
  TEXT$[9] = "　帰り道を覚えておかなければ。"
  LINE_COUNT = 10
ENDIF
RETURN

' ===== 二階1 =====
@S_UPSTAIRS1
TEXT$[0] = "　二階に着いた。"
TEXT$[1] = ""
TEXT$[2] = "　長い廊下に、いくつもの部屋が並んでいる。"
TEXT$[3] = "　ほとんどの扉は固く閉ざされている。"
TEXT$[4] = ""
TEXT$[5] = "　ふと、一番奥の部屋に気づいた。"
TEXT$[6] = "　扉の隙間から、微かに光が漏れている。"
TEXT$[7] = ""
TEXT$[8] = "　誰かいるのだろうか？"
TEXT$[9] = ""
TEXT$[10] = "　その時——"
TEXT$[11] = "　背後で物音がした。"
TEXT$[12] = ""
TEXT$[13] = "　振り返る。"
TEXT$[14] = "　...誰もいない。"
TEXT$[15] = ""
INC TENSION
TEXT$[16] = "【どうする？】"
TEXT$[17] = "　▶ 明かりの部屋へ向かう"
TEXT$[18] = "　　 すぐに階段を降りる"
LINE_COUNT = 19
MAX_CHOICE = 2
RETURN

' ===== 二階2 =====
@S_UPSTAIRS2
TEXT$[0] = "　廊下を進み、明かりの部屋へと向かう。"
TEXT$[1] = ""
TEXT$[2] = "　歩くたびに床が軋み、"
TEXT$[3] = "　壁際の古い調度品が揺れる。"
TEXT$[4] = ""
TEXT$[5] = "　途中、壁に掛けられた鏡の前を通る。"
TEXT$[6] = ""
IF TENSION >= 6 THEN
  TEXT$[7] = "　鏡に映った自分の背後に、"
  TEXT$[8] = "　誰かが立っている——"
  TEXT$[9] = ""
  TEXT$[10] = "　慌てて振り返るが、何もない。"
  TEXT$[11] = "　鏡を見直す。今度は自分だけだ。"
  TEXT$[12] = ""
  TEXT$[13] = "　...見間違いにしては、"
  TEXT$[14] = "　あまりにも鮮明だった。"
  LINE_COUNT = 15
ELSE
  TEXT$[7] = "　埃だらけの鏡に、"
  TEXT$[8] = "　自分の姿が薄ぼんやりと映る。"
  TEXT$[9] = ""
  TEXT$[10] = "　思ったより疲れた顔をしている。"
  LINE_COUNT = 11
ENDIF
INC TENSION
RETURN

' ===== 書斎1 =====
@S_LIBRARY1
TEXT$[0] = "　扉を開けると、そこは書斎だった。"
TEXT$[1] = ""
TEXT$[2] = "　壁一面の本棚に、古い書物が並んでいる。"
TEXT$[3] = "　机の上には、開かれたままの日記帳。"
TEXT$[4] = ""
TEXT$[5] = "　蝋燭が一本、机の上で揺れている。"
TEXT$[6] = "　これが廊下から見えた光源だ。"
TEXT$[7] = ""
TEXT$[8] = "　しかし..."
TEXT$[9] = "　蝋燭は半分以上残っている。"
TEXT$[10] = "　誰かがつい先ほど火をつけたのだ。"
TEXT$[11] = ""
TEXT$[12] = "【どうする？】"
TEXT$[13] = "　▶ 日記を読む"
TEXT$[14] = "　　 部屋を調べる"
TEXT$[15] = "　　 すぐに出る"
LINE_COUNT = 16
MAX_CHOICE = 3
RETURN

' ===== 書斎2 =====
@S_LIBRARY2
IF FLAGS[1] == 1 THEN
  ' 日記を読んだ
  TEXT$[0] = "　日記を手に取る。"
  TEXT$[1] = ""
  TEXT$[2] = "　最後のページには、震える筆跡で"
  TEXT$[3] = "　こう書かれていた。"
  TEXT$[4] = ""
  TEXT$[5] = "　『彼女は地下にいる。"
  TEXT$[6] = "　　決して扉を開けてはならない。"
  TEXT$[7] = "　　鍵は祭壇の下に隠した。』"
  TEXT$[8] = ""
  TEXT$[9] = "　『もし見つけても、"
  TEXT$[10] = "　　絶対に使ってはいけない。"
  TEXT$[11] = "　　彼女を自由にしてはいけないのだ。』"
  TEXT$[12] = ""
  TEXT$[13] = "　日記はそこで途切れていた。"
  TEXT$[14] = " "
  TEXT$[15] = "　「彼女」とは誰のことだろう..."
  LINE_COUNT = 16
  FLAGS[10] = 1  ' 日記情報フラグ
ELSEIF FLAGS[1] == 2 THEN
  ' 部屋を調べた
  TEXT$[0] = "　部屋を見回す。"
  TEXT$[1] = ""
  TEXT$[2] = "　本棚には古い洋書が並んでいるが、"
  TEXT$[3] = "　ほとんどが外国語で読めない。"
  TEXT$[4] = ""
  TEXT$[5] = "　ふと、本棚の一角に違和感を覚えた。"
  TEXT$[6] = "　他と比べて、埃が少ない場所がある。"
  TEXT$[7] = ""
  TEXT$[8] = "　そこを押してみると——"
  TEXT$[9] = "　カチリと音がして、本棚が動いた。"
  TEXT$[10] = ""
  TEXT$[11] = "　隠し通路だ。"
  TEXT$[12] = "　暗い階段が下へと続いている。"
  LINE_COUNT = 13
  FLAGS[11] = 1  ' 隠し通路発見フラグ
ELSE
  SCENE = 7  ' ホールに戻る
  GOSUB @LOAD_SCENE
  RETURN
ENDIF
RETURN

' ===== 隠し通路1 =====
@S_SECRET1
TEXT$[0] = "　隠し通路を進む。"
TEXT$[1] = ""
TEXT$[2] = "　狭い階段を降りていくと、"
TEXT$[3] = "　小さな部屋に出た。"
TEXT$[4] = ""
TEXT$[5] = "　部屋の中央には石の祭壇がある。"
TEXT$[6] = "　祭壇の上には、古い写真立てと"
TEXT$[7] = "　色褪せた花が置かれていた。"
TEXT$[8] = ""
TEXT$[9] = "　写真には若い女性が写っている。"
TEXT$[10] = "　美しい顔立ちだが..."
TEXT$[11] = "　目元だけが黒く塗りつぶされていた。"
TEXT$[12] = ""
TEXT$[13] = "　ホールの肖像画と同じだ。"
LINE_COUNT = 14
INC TENSION
INC TENSION
RETURN

' ===== 隠し通路2 =====
@S_SECRET2
TEXT$[0] = "　祭壇の下を調べてみる。"
TEXT$[1] = ""
IF FLAGS[10] == 1 THEN
  TEXT$[2] = "　日記に書かれていた通り、"
  TEXT$[3] = "　祭壇の下の隙間に何かがある。"
ELSE
  TEXT$[2] = "　何か引っかかりを感じた。"
  TEXT$[3] = "　祭壇の下に隙間がある。"
ENDIF
TEXT$[4] = ""
TEXT$[5] = "　手を伸ばすと、"
TEXT$[6] = "　冷たい金属の感触——"
TEXT$[7] = ""
TEXT$[8] = "　錆びた古い鍵だ。"
TEXT$[9] = ""
TEXT$[10] = "【鍵を取るか？】"
TEXT$[11] = "　▶ 鍵を取る"
TEXT$[12] = "　　 触らずにおく"
LINE_COUNT = 13
MAX_CHOICE = 2
RETURN

' ===== 地下1 =====
@S_BASEMENT1
TEXT$[0] = "　地下への扉を開ける。"
TEXT$[1] = ""
TEXT$[2] = "　冷たい空気が流れ出てきた。"
TEXT$[3] = "　カビの匂いと、何か別の..."
TEXT$[4] = "　嗅ぎ慣れない匂いが混じっている。"
TEXT$[5] = ""
TEXT$[6] = "　石造りの階段が暗闇へと続いている。"
TEXT$[7] = "　懐中電灯の光を向けても、"
TEXT$[8] = "　先が見えない。"
TEXT$[9] = ""
INC TENSION
TEXT$[10] = "【どうする？】"
TEXT$[11] = "　▶ 降りていく"
TEXT$[12] = "　　 引き返す"
LINE_COUNT = 13
MAX_CHOICE = 2
RETURN

' ===== 地下2 =====
@S_BASEMENT2
TEXT$[0] = "　階段を慎重に降りていく。"
TEXT$[1] = ""
TEXT$[2] = "　壁には古いランプが等間隔に並んでいるが、"
TEXT$[3] = "　どれも火は消えている。"
TEXT$[4] = ""
TEXT$[5] = "　やがて、突き当たりに着いた。"
TEXT$[6] = ""
TEXT$[7] = "　そこには、重厚な鉄の扉があった。"
TEXT$[8] = "　古めかしい錠前がかかっている。"
TEXT$[9] = ""
TEXT$[10] = "　扉の向こうから——"
TEXT$[11] = "　かすかな音が聞こえる。"
TEXT$[12] = ""
TEXT$[13] = "　「...たすけて...」"
TEXT$[14] = ""
TEXT$[15] = "　女の声だ。"
LINE_COUNT = 16
INC TENSION
INC TENSION
RETURN

' ===== 地下3 =====
@S_BASEMENT3
TEXT$[0] = "　扉の前で立ち止まる。"
TEXT$[1] = ""
IF FLAGS[10] == 1 THEN
  TEXT$[2] = "　日記の言葉が頭をよぎる。"
  TEXT$[3] = "　『決して扉を開けてはならない。』"
  TEXT$[4] = ""
  TEXT$[5] = "　しかし、中で誰かが助けを求めている..."
ELSE
  TEXT$[2] = "　中で誰かが閉じ込められている？"
  TEXT$[3] = "　助けなければ..."
  TEXT$[4] = ""
  TEXT$[5] = "　しかし、なぜこんな場所に？"
ENDIF
TEXT$[6] = ""
IF FLAGS[2] == 1 THEN
  TEXT$[7] = "　手の中には、祭壇で見つけた鍵がある。"
  TEXT$[8] = "　この錠前に合うかもしれない。"
ELSE
  TEXT$[7] = "　錠前がかかっている。"
  TEXT$[8] = "　開けるには鍵が必要だ。"
ENDIF
TEXT$[9] = ""
TEXT$[10] = "【どうする？】"
IF FLAGS[2] == 1 THEN
  TEXT$[11] = "　▶ 鍵で扉を開ける"
  TEXT$[12] = "　　 扉を叩いて話しかける"
  TEXT$[13] = "　　 引き返す"
  MAX_CHOICE = 3
ELSE
  TEXT$[11] = "　▶ 扉を叩いて話しかける"
  TEXT$[12] = "　　 引き返して鍵を探す"
  MAX_CHOICE = 2
ENDIF
LINE_COUNT = 14
RETURN

' ===== 儀式の間 =====
@S_RITUAL
TEXT$[0] = "　鍵を錠前に差し込む。"
TEXT$[1] = ""
TEXT$[2] = "　カチリと音がして、錠が開いた。"
TEXT$[3] = ""
TEXT$[4] = "　重い扉を押し開ける——"
TEXT$[5] = ""
TEXT$[6] = "　そこは広い石室だった。"
TEXT$[7] = "　壁には奇妙な紋様が刻まれている。"
TEXT$[8] = ""
TEXT$[9] = "　部屋の中央に、何かがいる。"
TEXT$[10] = ""
TEXT$[11] = "　白い服を着た女性だ。"
TEXT$[12] = "　長い黒髪が床まで垂れている。"
TEXT$[13] = ""
TEXT$[14] = "　「...来てくれたのね」"
TEXT$[15] = ""
TEXT$[16] = "　女性がゆっくりとこちらを向く。"
LINE_COUNT = 17
INC TENSION
INC TENSION
INC TENSION
RETURN

' ===== 最終1 =====
@S_FINAL1
TEXT$[0] = "　女性の顔が露わになる——"
TEXT$[1] = ""
IF FLAGS[10] == 1 THEN
  TEXT$[2] = "　写真で見た顔だ。"
  TEXT$[3] = "　しかし、その目は..."
ELSE
  TEXT$[2] = "　美しい顔立ちだが、"
  TEXT$[3] = "　どこか人間離れした印象を受ける。"
ENDIF
TEXT$[4] = ""
TEXT$[5] = "　真っ黒な瞳が、こちらを見つめている。"
TEXT$[6] = "　瞳孔も虹彩もない、"
TEXT$[7] = "　闘のような黒。"
TEXT$[8] = ""
TEXT$[9] = "　「ずっと...待っていたの」"
TEXT$[10] = ""
TEXT$[11] = "　女性が一歩、近づいてくる。"
TEXT$[12] = ""
TEXT$[13] = "　逃げなければ——"
TEXT$[14] = "　そう思った時には、体が動かなかった。"
LINE_COUNT = 15
INC TENSION
RETURN

' ===== 最終2 =====
@S_FINAL2
TEXT$[0] = "　「あなたが...最後の...」"
TEXT$[1] = ""
TEXT$[2] = "　女性が手を伸ばしてくる。"
TEXT$[3] = ""
TEXT$[4] = "　白く細い指が、頬に触れようとする——"
TEXT$[5] = ""
TEXT$[6] = "　その瞬間。"
TEXT$[7] = ""
IF FLAGS[3] == 1 THEN
  ' お守りを持っている
  TEXT$[8] = "　ポケットの中の何かが、熱を持った。"
  TEXT$[9] = ""
  TEXT$[10] = "　お守りだ。"
  TEXT$[11] = "　玄関で拾ったあの古いお守りが、"
  TEXT$[12] = "　強い光を放っている。"
  TEXT$[13] = ""
  TEXT$[14] = "　「——ッ！」"
  TEXT$[15] = ""
  TEXT$[16] = "　女性が悲鳴を上げ、後ずさる。"
  LINE_COUNT = 17
ELSE
  TEXT$[8] = "　冷たい指が頬に触れた。"
  TEXT$[9] = ""
  TEXT$[10] = "　意識が急速に遠のいていく..."
  TEXT$[11] = ""
  TEXT$[12] = "　「やっと...一緒に...」"
  TEXT$[13] = ""
  TEXT$[14] = "　女性の囁きが、最後に聞こえた。"
  LINE_COUNT = 15
  ENDING = 4  ' BAD END
  SCENE = 100
  RETURN
ENDIF
RETURN

' ===== 脱出1 =====
@S_ESCAPE1
TEXT$[0] = "　今だ——"
TEXT$[1] = ""
TEXT$[2] = "　意識が戻った私は、"
TEXT$[3] = "　踵を返して走り出した。"
TEXT$[4] = ""
TEXT$[5] = "　背後から、甲高い叫び声が追いかけてくる。"
TEXT$[6] = ""
TEXT$[7] = "　「待って...置いていかないで...」"
TEXT$[8] = ""
TEXT$[9] = "　階段を駆け上がる。"
TEXT$[10] = "　ホールを突っ切る。"
TEXT$[11] = ""
TEXT$[12] = "　玄関の扉が見えた——"
LINE_COUNT = 13
RETURN

' ===== 脱出2 =====
@S_ESCAPE2
TEXT$[0] = "　扉に手をかける。"
TEXT$[1] = ""
TEXT$[2] = "　開かない。"
TEXT$[3] = ""
TEXT$[4] = "　「嘘だろ...！」"
TEXT$[5] = ""
TEXT$[6] = "　必死に扉を叩く。"
TEXT$[7] = "　背後の気配が近づいてくる。"
TEXT$[8] = ""
IF FLAGS[0] == 1 THEN
  ' 最初に声をかけていた
  TEXT$[9] = "　その時、外から声がした。"
  TEXT$[10] = "　「誰かいるのか!?」"
  TEXT$[11] = ""
  TEXT$[12] = "　扉が外から開かれる——"
  TEXT$[13] = "　登山者だ。偶然この館を見つけたらしい。"
  TEXT$[14] = ""
  TEXT$[15] = "　私は外へ転がり出た。"
  TEXT$[16] = "　振り返ると、館の中は真っ暗だった。"
  TEXT$[17] = "　女性の姿はどこにもない。"
  LINE_COUNT = 18
  ENDING = 1  ' TRUE END
ELSE
  TEXT$[9] = "　冷たい手が肩を掴んだ。"
  TEXT$[10] = ""
  TEXT$[11] = "　「もう...逃がさない...」"
  TEXT$[12] = ""
  TEXT$[13] = "　意識が闇に沈んでいく..."
  LINE_COUNT = 14
  ENDING = 5  ' DEAD END
ENDIF
SCENE = 100
RETURN

' ===== エンディング =====
@S_ENDING
IF ENDING == 1 THEN
  ' TRUE END
  TEXT$[0] = "　夜が明けた。"
  TEXT$[1] = ""
  TEXT$[2] = "　私は登山者に助けられ、"
  TEXT$[3] = "　無事に麓まで降りることができた。"
  TEXT$[4] = ""
  TEXT$[5] = "　後日、あの館について調べた。"
  TEXT$[6] = "　黒澤邸——明治時代の豪商の別荘。"
  TEXT$[7] = "　しかし、ある事件をきっかけに"
  TEXT$[8] = "　打ち捨てられたという。"
  TEXT$[9] = ""
  TEXT$[10] = "　その事件とは——"
  TEXT$[11] = "　当主の一人娘が行方不明になったこと。"
  TEXT$[12] = ""
  TEXT$[13] = "　彼女は今も、見つかっていない。"
  TEXT$[14] = ""
  TEXT$[15] = "　　　【 TRUE END 】"
  TEXT$[16] = "　　　～ 夜明けの生還者 ～"
  LINE_COUNT = 17
ELSEIF ENDING == 2 THEN
  ' GOOD END
  TEXT$[0] = "　鍵が強い光を放った。"
  TEXT$[1] = ""
  TEXT$[2] = "　女性は苦悶の表情を浮かべ、"
  TEXT$[3] = "　やがて霧のように消えていった。"
  TEXT$[4] = ""
  TEXT$[5] = "　「...ありがとう...」"
  TEXT$[6] = ""
  TEXT$[7] = "　最後に、そんな声が聞こえた気がした。"
  TEXT$[8] = ""
  TEXT$[9] = "　彼女は成仏したのだろうか。"
  TEXT$[10] = "　それとも、また眠りについただけなのか。"
  TEXT$[11] = ""
  TEXT$[12] = "　答えは、わからない。"
  TEXT$[13] = ""
  TEXT$[14] = "　　　【 GOOD END 】"
  TEXT$[15] = "　　　～ 封印の鍵 ～"
  LINE_COUNT = 16
ELSEIF ENDING == 3 THEN
  ' NORMAL END
  TEXT$[0] = "　私は館を出ることに成功した。"
  TEXT$[1] = ""
  TEXT$[2] = "　夜明けの光の中、振り返ると"
  TEXT$[3] = "　館は静かに佇んでいた。"
  TEXT$[4] = ""
  TEXT$[5] = "　二階の窓から、"
  TEXT$[6] = "　誰かがこちらを見ている気がした。"
  TEXT$[7] = ""
  TEXT$[8] = "　しかしそれも、光の加減かもしれない。"
  TEXT$[9] = ""
  TEXT$[10] = "　あの館で何があったのか。"
  TEXT$[11] = "　今となっては、夢だったようにも思える。"
  TEXT$[12] = ""
  TEXT$[13] = "　　　【 NORMAL END 】"
  TEXT$[14] = "　　　～ 夜明け前 ～"
  LINE_COUNT = 15
ELSEIF ENDING == 4 THEN
  ' BAD END
  TEXT$[0] = "　意識が戻った時、"
  TEXT$[1] = "　私は石室の中に横たわっていた。"
  TEXT$[2] = ""
  TEXT$[3] = "　体が動かない。"
  TEXT$[4] = "　いや、動かす気力がない。"
  TEXT$[5] = ""
  TEXT$[6] = "　傍らに、あの女性が座っている。"
  TEXT$[7] = "　優しく、髪を撫でてくれている。"
  TEXT$[8] = ""
  TEXT$[9] = "　「もう...一人じゃないわ...」"
  TEXT$[10] = ""
  TEXT$[11] = "　ああ、このままでもいいか——"
  TEXT$[12] = "　そんな考えが浮かんだ。"
  TEXT$[13] = ""
  TEXT$[14] = "　　　【 BAD END 】"
  TEXT$[15] = "　　　～ 闇に囚われし者 ～"
  LINE_COUNT = 16
ELSEIF ENDING == 5 THEN
  ' DEAD END
  TEXT$[0] = "　翌朝。"
  TEXT$[1] = ""
  TEXT$[2] = "　山道で故障した車が発見された。"
  TEXT$[3] = "　運転席には荷物が残されていたが、"
  TEXT$[4] = "　ドライバーの姿はなかった。"
  TEXT$[5] = ""
  TEXT$[6] = "　捜索隊が組織されたが、"
  TEXT$[7] = "　ドライバーは見つからなかった。"
  TEXT$[8] = ""
  TEXT$[9] = "　ただ、奇妙な報告がひとつ。"
  TEXT$[10] = ""
  TEXT$[11] = "　山の上に古い洋館があり、"
  TEXT$[12] = "　その窓から二つの人影が"
  TEXT$[13] = "　こちらを見ていた——という証言が。"
  TEXT$[14] = ""
  TEXT$[15] = "　　　【 DEAD END 】"
  TEXT$[16] = "　　　～ 館の住人 ～"
  LINE_COUNT = 17
ELSEIF ENDING == 6 THEN
  ' SECRET END
  TEXT$[0] = "　車の中で朝を待つことにした。"
  TEXT$[1] = ""
  TEXT$[2] = "　シートを倒し、毛布にくるまる。"
  TEXT$[3] = "　不安はあったが、疲れが勝った。"
  TEXT$[4] = ""
  TEXT$[5] = "　夢を見た。"
  TEXT$[6] = "　古い洋館の夢。"
  TEXT$[7] = "　白い服の女性が、悲しそうに"
  TEXT$[8] = "　こちらを見ている夢。"
  TEXT$[9] = ""
  TEXT$[10] = "　目が覚めると、朝だった。"
  TEXT$[11] = "　エンジンは何事もなく始動した。"
  TEXT$[12] = ""
  TEXT$[13] = "　山の上を見上げる。"
  TEXT$[14] = "　建物らしきものは、何も見えなかった。"
  TEXT$[15] = ""
  TEXT$[16] = "　　　【 SECRET END 】"
  TEXT$[17] = "　　　～ 夢の中の出会い ～"
  LINE_COUNT = 18
ELSE
  ' ANOTHER END
  TEXT$[0] = "　全てが終わった。"
  TEXT$[1] = ""
  TEXT$[2] = "　私は館から解放された。"
  TEXT$[3] = "　しかし、心の中には"
  TEXT$[4] = "　消えない影が残っている。"
  TEXT$[5] = ""
  TEXT$[6] = "　時々、夢に見る。"
  TEXT$[7] = "　あの女性の姿を。"
  TEXT$[8] = "　あの黒い瞳を。"
  TEXT$[9] = ""
  TEXT$[10] = "　彼女は今も、あの館で"
  TEXT$[11] = "　誰かを待っているのだろうか。"
  TEXT$[12] = ""
  TEXT$[13] = "　　　【 ANOTHER END 】"
  TEXT$[14] = "　　　～ 忘れられぬ影 ～"
  LINE_COUNT = 15
ENDIF

TEXT$[LINE_COUNT] = ""
TEXT$[LINE_COUNT + 1] = ""
TEXT$[LINE_COUNT + 2] = "　　Aボタンでタイトルへ"
LINE_COUNT = LINE_COUNT + 3
RETURN

' ===== 更新処理 =====
@UPDATE
VAR B = BUTTON(2)

IF TYPING_LINE < LINE_COUNT - MAX_CHOICE - 2 THEN
  INC TYPING_POS
  IF TYPING_POS >= LEN(TEXT$[TYPING_LINE]) * TEXT_SPEED THEN
    TYPING_POS = 0
    INC TYPING_LINE
  ENDIF
  IF B AND 16 THEN
    TYPING_LINE = LINE_COUNT - MAX_CHOICE - 2
    IF MAX_CHOICE == 0 THEN TYPING_LINE = LINE_COUNT
  ENDIF
  RETURN
ENDIF

IF MAX_CHOICE > 0 THEN
  IF B AND 1 THEN CHOICE = (CHOICE - 1 + MAX_CHOICE) MOD MAX_CHOICE
  IF B AND 2 THEN CHOICE = (CHOICE + 1) MOD MAX_CHOICE
  IF B AND 16 THEN
    GOSUB @PROCESS_CHOICE
    BEEP 0
  ENDIF
ELSE
  IF B AND 16 THEN
    GOSUB @NEXT_SCENE
    BEEP 0
  ENDIF
ENDIF
RETURN

' ===== 選択処理 =====
@PROCESS_CHOICE
IF SCENE == 3 THEN
  ' プロローグ：車で待つ/建物へ
  IF CHOICE == 0 THEN
    ENDING = 6  ' SECRET END
    SCENE = 100
  ELSE
    SCENE = 4
  ENDIF
ELSEIF SCENE == 5 THEN
  ' 玄関：ノック/そっと入る
  IF CHOICE == 0 THEN FLAGS[0] = 1
  SCENE = 6
ELSEIF SCENE == 7 THEN
  ' ホール：二階/地下/廊下
  IF CHOICE == 0 THEN SCENE = 8
  IF CHOICE == 1 THEN SCENE = 15
  IF CHOICE == 2 THEN SCENE = 8
ELSEIF SCENE == 10 THEN
  ' 二階：明かりの部屋/降りる
  IF CHOICE == 0 THEN
    SCENE = 11
  ELSE
    ENDING = 3  ' NORMAL END
    SCENE = 100
  ENDIF
ELSEIF SCENE == 12 THEN
  ' 書斎：日記/調べる/出る
  IF CHOICE == 0 THEN FLAGS[1] = 1
  IF CHOICE == 1 THEN FLAGS[1] = 2
  IF CHOICE == 2 THEN FLAGS[1] = 0
  SCENE = 13
ELSEIF SCENE == 14 THEN
  ' 隠し通路：鍵を取る/取らない
  IF CHOICE == 0 THEN FLAGS[2] = 1
  SCENE = 15
ELSEIF SCENE == 16 THEN
  ' 地下入口：降りる/戻る
  IF CHOICE == 0 THEN
    SCENE = 17
  ELSE
    SCENE = 7
  ENDIF
ELSEIF SCENE == 18 THEN
  ' 地下扉前
  IF FLAGS[2] == 1 THEN
    IF CHOICE == 0 THEN SCENE = 19  ' 扉を開ける
    IF CHOICE == 1 THEN SCENE = 17  ' 話しかける
    IF CHOICE == 2 THEN
      ENDING = 3  ' NORMAL END
      SCENE = 100
    ENDIF
  ELSE
    IF CHOICE == 0 THEN SCENE = 17  ' 話しかける
    IF CHOICE == 1 THEN SCENE = 13  ' 鍵を探す
  ENDIF
ENDIF

GOSUB @LOAD_SCENE
RETURN

' ===== 次のシーンへ =====
@NEXT_SCENE
IF SCENE >= 100 THEN
  GOSUB @INIT_GAME
  RETURN
ENDIF

INC SCENE
GOSUB @LOAD_SCENE
RETURN

' ===== 描画 =====
@DRAW
' 背景（緊張度で色を変える）
VAR BG_R = MIN(TENSION * 8, 40)
VAR BG = RGB(BG_R, 0, 20 - TENSION)
GFILL 0, 0, 319, 239, BG

' テキストウィンドウ
GFILL 5, 30, 315, 225, #000000
GBOX 5, 30, 315, 225, #444488

' シーン番号（デバッグ用は消す）
' LOCATE 0, 0 : COLOR #333333 : PRINT "S:"; SCENE; " T:"; TENSION

' テキスト表示
FOR I = 0 TO MIN(TYPING_LINE, LINE_COUNT - 1)
  VAR TXT$ = TEXT$[I]
  
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
  
  IF I == TYPING_LINE AND TYPING_LINE < LINE_COUNT - MAX_CHOICE THEN
    VAR SHOW_LEN = TYPING_POS / TEXT_SPEED
    TXT$ = LEFT$(TXT$, SHOW_LEN)
  ENDIF
  
  LOCATE 1, 4 + I : PRINT TXT$
NEXT

COLOR #FFFFFF
RETURN
