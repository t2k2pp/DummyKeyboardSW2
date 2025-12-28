import { useState, useRef, useCallback } from 'react'
import './App.css'
import { Lexer } from './core/lexer'
import { Parser } from './core/parser'
import { Runtime } from './core/runtime'

// サンプルコード
const SAMPLE_CODE = `' スネークゲーム
OPTION STRICT
ACLS

CONST GW = 20
CONST GH = 15
CONST CS = 16

DIM SX[300], SY[300]
DIM SLEN, DIR
DIM FX, FY
DIM SCORE, SPEED, GAME_OVER

GOSUB @GAME_INIT

LOOP
  VSYNC
  IF GAME_OVER THEN
    GOSUB @DRAW_GAMEOVER
  ELSE
    GOSUB @INPUT
    GOSUB @UPDATE
    GOSUB @DRAW
  ENDIF
ENDLOOP

@GAME_INIT
SLEN = 3
DIR = 8
FOR I = 0 TO SLEN - 1
  SX[I] = GW / 2 - I
  SY[I] = GH / 2
NEXT
FX = RND(GW)
FY = RND(GH)
SCORE = 0
SPEED = 8
GAME_OVER = FALSE
RETURN

@INPUT
VAR B = BUTTON(0)
IF B AND 1 THEN DIR = 1
IF B AND 2 THEN DIR = 2
IF B AND 4 THEN DIR = 4
IF B AND 8 THEN DIR = 8
RETURN

@UPDATE
VAR NX = SX[0]
VAR NY = SY[0]
IF DIR == 1 THEN NY = NY - 1
IF DIR == 2 THEN NY = NY + 1
IF DIR == 4 THEN NX = NX - 1
IF DIR == 8 THEN NX = NX + 1

IF NX < 0 OR NX >= GW OR NY < 0 OR NY >= GH THEN
  GAME_OVER = TRUE
  RETURN
ENDIF

FOR I = SLEN - 1 TO 1 STEP -1
  SX[I] = SX[I - 1]
  SY[I] = SY[I - 1]
NEXT
SX[0] = NX
SY[0] = NY

IF NX == FX AND NY == FY THEN
  SLEN = SLEN + 1
  FX = RND(GW)
  FY = RND(GH)
  SCORE = SCORE + 10
  BEEP 2
ENDIF
RETURN

@DRAW
GFILL 0, 0, 319, 239, #001100

FOR I = 0 TO SLEN - 1
  VAR X = SX[I] * CS
  VAR Y = SY[I] * CS
  IF I == 0 THEN
    GFILL X, Y, X + CS - 2, Y + CS - 2, #00FF00
  ELSE
    GFILL X, Y, X + CS - 2, Y + CS - 2, #008800
  ENDIF
NEXT

VAR FFX = FX * CS
VAR FFY = FY * CS
GFILL FFX, FFY, FFX + CS - 2, FFY + CS - 2, #FF0000

LOCATE 0, 0
COLOR #FFFFFF
PRINT "SCORE: "; SCORE
RETURN

@DRAW_GAMEOVER
GFILL 80, 80, 240, 160, #000000
GBOX 80, 80, 240, 160, #FF0000
LOCATE 12, 13
COLOR #FF0000
PRINT "GAME OVER"
LOCATE 10, 15
COLOR #FFFFFF
PRINT "SCORE: "; SCORE
RETURN
`;

function App() {
  const [code, setCode] = useState(SAMPLE_CODE);
  const [isRunning, setIsRunning] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const graphicsCanvasRef = useRef<HTMLCanvasElement>(null);
  const textCanvasRef = useRef<HTMLCanvasElement>(null);
  const runtimeRef = useRef<Runtime | null>(null);

  const handleRun = useCallback(() => {
    if (!graphicsCanvasRef.current || !textCanvasRef.current) return;

    setErrorMsg('');
    try {
      const lexer = new Lexer(code);
      const tokens = lexer.tokenize();
      const parser = new Parser(tokens);
      const ast = parser.parse();

      const runtime = new Runtime(graphicsCanvasRef.current, textCanvasRef.current);
      runtimeRef.current = runtime;
      runtime.load(ast);

      setIsRunning(true);
      runtime.run().then(() => {
        setIsRunning(false);
      });
    } catch (e) {
      setErrorMsg(String(e));
      setIsRunning(false);
    }
  }, [code]);

  const handleStop = useCallback(() => {
    if (runtimeRef.current) {
      runtimeRef.current.stop();
    }
    setIsRunning(false);
  }, []);

  const handleLoadSample = (name: string) => {
    // 将来的にサンプルを選択可能に
    setCode(SAMPLE_CODE);
  };

  return (
    <div className="app">
      <header className="header">
        <h1>🎮 プチコン4 エミュレータ</h1>
        <span className="subtitle">SmileBASIC Web Simulator</span>
      </header>

      <div className="main-container">
        <div className="editor-panel">
          <div className="panel-header">
            <span>📝 コードエディタ</span>
            <select onChange={(e) => handleLoadSample(e.target.value)}>
              <option value="">サンプル選択</option>
              <option value="snake">スネーク</option>
              <option value="pong">ピンポン</option>
            </select>
          </div>
          <textarea
            className="code-editor"
            value={code}
            onChange={(e) => setCode(e.target.value)}
            spellCheck={false}
          />
        </div>

        <div className="screen-panel">
          <div className="panel-header">
            <span>📺 実行画面</span>
            <div className="controls">
              {!isRunning ? (
                <button className="run-btn" onClick={handleRun}>▶ 実行</button>
              ) : (
                <button className="stop-btn" onClick={handleStop}>■ 停止</button>
              )}
            </div>
          </div>
          <div className="screen-container">
            <canvas
              ref={graphicsCanvasRef}
              width={320}
              height={240}
              className="game-canvas graphics-layer"
            />
            <canvas
              ref={textCanvasRef}
              width={320}
              height={240}
              className="game-canvas text-layer"
            />
          </div>
          <div className="key-guide">
            <span>↑↓←→: 移動</span>
            <span>Z/Enter: A</span>
            <span>X/BS: B</span>
          </div>
          {errorMsg && <div className="error-msg">{errorMsg}</div>}
        </div>
      </div>
    </div>
  )
}

export default App
