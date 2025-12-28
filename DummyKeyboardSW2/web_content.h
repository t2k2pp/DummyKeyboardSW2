/*
 * ESP32 Bluetooth Keyboard for Switch 2
 * Web Content (HTML/CSS/JavaScript)
 * 
 * PC向けWebアプリのコンテンツを格納
 */

#ifndef WEB_CONTENT_H
#define WEB_CONTENT_H

const char INDEX_HTML[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Switch Keyboard - Dummy Keyboard for Switch 2</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', 'Hiragino Kaku Gothic ProN', 'Yu Gothic', sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            min-height: 100vh;
            color: #e4e4e4;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        h1 {
            font-size: 2rem;
            background: linear-gradient(90deg, #00d9ff, #00ff88);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #888;
            font-size: 0.9rem;
        }
        
        .status-bar {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        
        .status-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 25px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        
        .status-dot.connected {
            background: #00ff88;
            box-shadow: 0 0 10px #00ff88;
        }
        
        .status-dot.disconnected {
            background: #ff4444;
            box-shadow: 0 0 10px #ff4444;
        }
        
        .status-dot.sending {
            background: #ffaa00;
            box-shadow: 0 0 10px #ffaa00;
            animation: blink 0.5s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.6; }
        }
        
        @keyframes blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.3; }
        }
        
        .card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 20px;
            backdrop-filter: blur(10px);
        }
        
        .card-title {
            font-size: 1.1rem;
            margin-bottom: 15px;
            color: #00d9ff;
        }
        
        textarea {
            width: 100%;
            height: 300px;
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 15px;
            color: #e4e4e4;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 14px;
            resize: vertical;
            transition: border-color 0.3s;
        }
        
        textarea:focus {
            outline: none;
            border-color: #00d9ff;
            box-shadow: 0 0 20px rgba(0, 217, 255, 0.2);
        }
        
        textarea::placeholder {
            color: #666;
        }
        
        .controls {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: center;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #00d9ff, #00ff88);
            color: #1a1a2e;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(0, 217, 255, 0.3);
        }
        
        .btn-primary:disabled {
            background: #444;
            color: #888;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: #e4e4e4;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #ff4444, #ff6666);
            color: #fff;
        }
        
        .slider-container {
            flex: 1;
            min-width: 200px;
        }
        
        .slider-label {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 0.85rem;
            color: #888;
        }
        
        input[type="range"] {
            width: 100%;
            height: 6px;
            border-radius: 3px;
            background: rgba(255, 255, 255, 0.1);
            outline: none;
            -webkit-appearance: none;
        }
        
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            background: #00d9ff;
            cursor: pointer;
            box-shadow: 0 0 10px rgba(0, 217, 255, 0.5);
        }
        
        .progress-container {
            margin-top: 20px;
            display: none;
        }
        
        .progress-container.active {
            display: block;
        }
        
        .progress-bar {
            height: 8px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 4px;
            overflow: hidden;
            margin-bottom: 10px;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #00d9ff, #00ff88);
            border-radius: 4px;
            transition: width 0.3s;
            width: 0%;
        }
        
        .progress-text {
            display: flex;
            justify-content: space-between;
            font-size: 0.85rem;
            color: #888;
        }
        
        .log-container {
            max-height: 150px;
            overflow-y: auto;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.85rem;
        }
        
        .log-entry {
            padding: 5px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            display: flex;
            gap: 10px;
        }
        
        .log-time {
            color: #666;
        }
        
        .log-message {
            color: #00ff88;
        }
        
        .log-error {
            color: #ff4444;
        }

        .char-count {
            text-align: right;
            font-size: 0.85rem;
            color: #666;
            margin-top: 8px;
        }

        footer {
            text-align: center;
            margin-top: 30px;
            color: #555;
            font-size: 0.85rem;
        }

        footer a {
            color: #00d9ff;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>⌨️ Switch Keyboard</h1>
            <p class="subtitle">ESP32 BLE Keyboard for Switch 2 / プチコン4</p>
        </header>
        
        <div class="status-bar">
            <div class="status-item">
                <span class="status-dot" id="bleStatus"></span>
                <span id="bleStatusText">BLE: 確認中...</span>
            </div>
            <div class="status-item">
                <span class="status-dot connected"></span>
                <span>WiFi: 接続中</span>
            </div>
        </div>
        
        <div class="card">
            <h2 class="card-title">📝 入力テキスト</h2>
            <textarea id="inputText" placeholder="ここにプチコン4に入力したいテキストを貼り付けてください...

例：
PRINT &quot;HELLO, WORLD!&quot;
FOR I=0 TO 10
  PRINT I
NEXT"></textarea>
            <div class="char-count"><span id="charCount">0</span> 文字</div>
        </div>
        
        <div class="card">
            <h2 class="card-title">⚙️ 設定 & 送信</h2>
            <div class="controls">
                <button class="btn btn-primary" id="sendBtn" onclick="sendText()">
                    <span>▶</span> 送信開始
                </button>
                <button class="btn btn-danger" id="stopBtn" onclick="stopSending()" style="display:none;">
                    <span>■</span> 停止
                </button>
                <button class="btn btn-secondary" onclick="clearText()">
                    クリア
                </button>
                <div class="slider-container">
                    <div class="slider-label">
                        <span>入力速度</span>
                        <span id="delayValue">30ms</span>
                    </div>
                    <input type="range" id="delaySlider" min="10" max="100" value="30" onchange="updateDelay()">
                </div>
            </div>
            
            <div class="progress-container" id="progressContainer">
                <div class="progress-bar">
                    <div class="progress-fill" id="progressFill"></div>
                </div>
                <div class="progress-text">
                    <span id="progressChars">0 / 0 文字</span>
                    <span id="progressPercent">0%</span>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2 class="card-title">📋 ログ</h2>
            <div class="log-container" id="logContainer"></div>
        </div>
        
        <footer>
            <p>Dummy Keyboard for Switch 2 | <a href="https://github.com/t2k2pp/DummyKeyboardSW2" target="_blank">GitHub</a></p>
        </footer>
    </div>
    
    <script>
        let isSending = false;
        let statusInterval = null;
        
        // ページ読み込み時に状態を確認
        document.addEventListener('DOMContentLoaded', () => {
            checkStatus();
            statusInterval = setInterval(checkStatus, 3000);
            
            document.getElementById('inputText').addEventListener('input', updateCharCount);
        });
        
        function updateCharCount() {
            const text = document.getElementById('inputText').value;
            document.getElementById('charCount').textContent = text.length;
        }
        
        function updateDelay() {
            const delay = document.getElementById('delaySlider').value;
            document.getElementById('delayValue').textContent = delay + 'ms';
        }
        
        async function checkStatus() {
            try {
                const response = await fetch('/status');
                const data = await response.json();
                
                const bleStatus = document.getElementById('bleStatus');
                const bleStatusText = document.getElementById('bleStatusText');
                
                if (data.bleConnected) {
                    bleStatus.className = 'status-dot connected';
                    bleStatusText.textContent = 'BLE: 接続中';
                } else {
                    bleStatus.className = 'status-dot disconnected';
                    bleStatusText.textContent = 'BLE: 未接続';
                }
                
                if (data.isSending) {
                    updateProgress(data.progress, data.total);
                }
            } catch (e) {
                log('状態取得エラー: ' + e.message, true);
            }
        }
        
        function updateProgress(current, total) {
            const percent = total > 0 ? Math.round((current / total) * 100) : 0;
            document.getElementById('progressFill').style.width = percent + '%';
            document.getElementById('progressChars').textContent = current + ' / ' + total + ' 文字';
            document.getElementById('progressPercent').textContent = percent + '%';
        }
        
        async function sendText() {
            const text = document.getElementById('inputText').value;
            if (!text.trim()) {
                log('テキストを入力してください', true);
                return;
            }
            
            const delay = document.getElementById('delaySlider').value;
            
            try {
                document.getElementById('sendBtn').style.display = 'none';
                document.getElementById('stopBtn').style.display = 'inline-flex';
                document.getElementById('progressContainer').classList.add('active');
                isSending = true;
                
                log('送信開始: ' + text.length + '文字');
                
                const response = await fetch('/send', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'text=' + encodeURIComponent(text) + '&delay=' + delay
                });
                
                const result = await response.json();
                
                if (result.success) {
                    log('送信完了: ' + result.message);
                    updateProgress(text.length, text.length);
                } else {
                    log('送信エラー: ' + result.message, true);
                }
            } catch (e) {
                log('通信エラー: ' + e.message, true);
            } finally {
                isSending = false;
                document.getElementById('sendBtn').style.display = 'inline-flex';
                document.getElementById('stopBtn').style.display = 'none';
            }
        }
        
        async function stopSending() {
            try {
                await fetch('/stop', { method: 'POST' });
                log('送信を停止しました');
            } catch (e) {
                log('停止エラー: ' + e.message, true);
            }
            
            isSending = false;
            document.getElementById('sendBtn').style.display = 'inline-flex';
            document.getElementById('stopBtn').style.display = 'none';
        }
        
        function clearText() {
            document.getElementById('inputText').value = '';
            updateCharCount();
            document.getElementById('progressContainer').classList.remove('active');
            updateProgress(0, 0);
            log('テキストをクリアしました');
        }
        
        function log(message, isError = false) {
            const container = document.getElementById('logContainer');
            const entry = document.createElement('div');
            entry.className = 'log-entry';
            
            const time = new Date().toLocaleTimeString('ja-JP');
            entry.innerHTML = `
                <span class="log-time">[${time}]</span>
                <span class="${isError ? 'log-error' : 'log-message'}">${message}</span>
            `;
            
            container.insertBefore(entry, container.firstChild);
            
            // 最大20件まで保持
            while (container.children.length > 20) {
                container.removeChild(container.lastChild);
            }
        }
    </script>
</body>
</html>
)rawliteral";

#endif // WEB_CONTENT_H
