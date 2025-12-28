import { useState, useRef, useCallback, useEffect } from 'react'
import './App.css'
import { Lexer } from './interpreter/lexer'
import { Parser } from './interpreter/parser'
import { Runtime } from './interpreter/runtime'

// サンプルコード（スネークゲーム）
const SAMPLE_SNAKE = `' スネークゲーム
OPTION STRICT
ACLS

CONST GW = 20
CONST GH = 15
CONST CS = 16

DIM SX[300], SY[300]
DIM SLEN, DIR
DIM FX, FY
DIM SCORE, GAME_OVER

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
SLEN = 3 : DIR = 8
FOR I = 0 TO SLEN - 1
  SX[I] = GW / 2 - I : SY[I] = GH / 2
NEXT
FX = RND(GW) : FY = RND(GH)
SCORE = 0 : GAME_OVER = FALSE
RETURN

@INPUT
VAR B = BUTTON(0)
IF B AND 1 THEN DIR = 1
IF B AND 2 THEN DIR = 2
IF B AND 4 THEN DIR = 4
IF B AND 8 THEN DIR = 8
RETURN

@UPDATE
VAR NX = SX[0] : VAR NY = SY[0]
IF DIR == 1 THEN NY = NY - 1
IF DIR == 2 THEN NY = NY + 1
IF DIR == 4 THEN NX = NX - 1
IF DIR == 8 THEN NX = NX + 1

IF NX < 0 OR NX >= GW OR NY < 0 OR NY >= GH THEN
  GAME_OVER = TRUE : RETURN
ENDIF

FOR I = SLEN - 1 TO 1 STEP -1
  SX[I] = SX[I - 1] : SY[I] = SY[I - 1]
NEXT
SX[0] = NX : SY[0] = NY

IF NX == FX AND NY == FY THEN
  SLEN = SLEN + 1
  FX = RND(GW) : FY = RND(GH)
  SCORE = SCORE + 10
  BEEP 2
ENDIF
RETURN

@DRAW
GFILL 0, 0, 319, 239, #001100
FOR I = 0 TO SLEN - 1
  VAR X = SX[I] * CS : VAR Y = SY[I] * CS
  IF I == 0 THEN
    GFILL X, Y, X + CS - 2, Y + CS - 2, #00FF00
  ELSE
    GFILL X, Y, X + CS - 2, Y + CS - 2, #008800
  ENDIF
NEXT
VAR FFX = FX * CS : VAR FFY = FY * CS
GFILL FFX, FFY, FFX + CS - 2, FFY + CS - 2, #FF0000
LOCATE 0, 0 : COLOR #FFFFFF
PRINT "SCORE: "; SCORE
RETURN

@DRAW_GAMEOVER
GFILL 80, 80, 240, 160, #000000
GBOX 80, 80, 240, 160, #FF0000
LOCATE 12, 13 : COLOR #FF0000
PRINT "GAME OVER"
LOCATE 10, 15 : COLOR #FFFFFF
PRINT "SCORE: "; SCORE
RETURN
`;

interface SampleProgram {
  name: string;
  code: string;
}

const SAMPLES: SampleProgram[] = [
  { name: 'スネーク', code: SAMPLE_SNAKE },
];

function App() {
  const [code, setCode] = useState(SAMPLE_SNAKE);
  const [isRunning, setIsRunning] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [selectedSample, setSelectedSample] = useState('スネーク');
  const graphicsRef = useRef<HTMLCanvasElement>(null);
  const textRef = useRef<HTMLCanvasElement>(null);
  const runtimeRef = useRef<Runtime | null>(null);

  const handleRun = useCallback(() => {
    if (!graphicsRef.current || !textRef.current) return;

    setErrorMsg('');
    try {
      const lexer = new Lexer(code);
      const tokens = lexer.tokenize();
      const parser = new Parser();
      const ast = parser.parse(tokens);

      const runtime = new Runtime(graphicsRef.current, textRef.current);
      runtimeRef.current = runtime;
      runtime.load(ast);

      setIsRunning(true);
      runtime.run().then(() => {
        setIsRunning(false);
      }).catch(e => {
        setErrorMsg(String(e));
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

  const handleSampleChange = (name: string) => {
    const sample = SAMPLES.find(s => s.name === name);
    if (sample) {
      setCode(sample.code);
      setSelectedSample(name);
    }
  };

  useEffect(() => {
    // 初期化時にキャンバスをクリア
    if (graphicsRef.current && textRef.current) {
      const ctx = graphicsRef.current.getContext('2d');
      if (ctx) {
        ctx.fillStyle = '#000000';
        ctx.fillRect(0, 0, 320, 240);
      }
    }
  }, []);

  return (
    <div className="app">
      <header className="header">
        <h1>🎮 プチコン4 エミュレータ v2</h1>
        <span className="subtitle">SmileBASIC Web Interpreter</span>
      </header>

      <div className="main-container">
        <div className="editor-panel">
          <div className="panel-header">
            <span>📝 コードエディタ</span>
            <select
              value={selectedSample}
              onChange={(e) => handleSampleChange(e.target.value)}
            >
              {SAMPLES.map(s => (
                <option key={s.name} value={s.name}>{s.name}</option>
              ))}
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
              ref={graphicsRef}
              width={320}
              height={240}
              className="game-canvas graphics-layer"
            />
            <canvas
              ref={textRef}
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
