# Switch Keyboard - ESP32 BLE Keyboard for Switch 2

ESP32を使用して、PC向けWebアプリからテキストを受信し、Nintendo Switch 2にBluetoothキーボードとして入力を行うダミーキーボードです。

**主な用途**: プチコン4に生成AIで作成したプログラムを流し込む

## 🎮 機能

- **Webアプリ**: PCのブラウザからテキストを入力・送信
- **BLEキーボード**: Switch 2にBluetoothキーボードとして認識
- **入力速度調整**: 10ms〜100msの間で調整可能
- **進行状況表示**: 送信中の進行状況をリアルタイム表示

## 📦 必要なハードウェア

- Geekcreit® ESP32 30ピン開発ボード（または互換ボード）
- USB Micro-Bケーブル（ESP32書き込み用）
- WiFiネットワーク

## 🔧 セットアップ

### 1. Arduino IDE準備

1. [Arduino IDE](https://www.arduino.cc/en/software)をインストール
2. ESP32ボードマネージャを追加:
   - ファイル → 環境設定 → 追加のボードマネージャURL
   - `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
3. ツール → ボード → ボードマネージャ → 「ESP32」を検索してインストール

### 2. ESP32-BLE-Keyboardライブラリ

1. [ESP32-BLE-Keyboard](https://github.com/T-vK/ESP32-BLE-Keyboard/releases)から最新版をダウンロード
2. Arduino IDE: スケッチ → ライブラリをインクルード → .ZIP形式のライブラリを追加

### 3. WiFi設定

`DummyKeyboardSW2/config.h`を編集:

```cpp
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
```

### 4. 書き込み

1. ESP32をPCに接続
2. ツール → ボード → ESP32 Dev Module
3. ツール → ポート → 該当するCOMポートを選択
4. スケッチ → マイコンボードに書き込む

## 🚀 使用方法

### Step 1: ESP32を起動

- ESP32に電源を入れる
- シリアルモニタ（115200bps）でIPアドレスを確認

```
[WiFi] Connected!
[WiFi] IP Address: 192.168.1.100
[Web] Server started on port 80
```

### Step 2: Switch 2とペアリング

1. Switch 2の設定 → Bluetooth機器
2. 「Switch Keyboard」を探してペアリング

### Step 3: Webアプリからテキスト送信

1. PCのブラウザで `http://<ESP32のIPアドレス>/` を開く
2. テキストエリアにプログラムを貼り付け
3. 「送信開始」ボタンをクリック

## ⚙️ 設定項目

| 項目 | ファイル | 説明 |
|------|----------|------|
| WiFi SSID/Password | `config.h` | WiFiネットワーク設定 |
| BLEデバイス名 | `config.h` | Bluetoothに表示される名前 |
| キー入力間隔 | `config.h` / WebUI | 1文字ごとの待機時間(ms) |

## ⚠️ 注意事項

- **BLE互換性**: Switch 2がBLEキーボードを拒否する場合は、USB HIDキーボード（ESP32-S3使用）への変更を検討
- **日本語入力**: BLE HIDキーボードはASCII文字のみ対応。日本語はローマ字入力を使用
- **入力速度**: 速すぎると文字の取りこぼしが発生。問題がある場合は速度を下げる

## 🔍 トラブルシューティング

### WiFi接続できない

1. `config.h`のSSIDとパスワードを確認
2. ESP32とルーターの距離を近づける
3. シリアルモニタで接続状態を確認
4. 接続失敗時は自動的にAPモード（`SwitchKeyboard` / `12345678`）で起動

### Switch 2にペアリングできない

**現象**: 「Switch Keyboard」が見つからない、または「Bluetoothオーディオ」として認識される

**対処法**:
1. ESP32を再起動し、シリアルモニタで `[BLE] BLE Keyboard started` を確認
2. Switch 2のBluetooth設定で一度削除してから再ペアリング
3. 他のBLEデバイスの電源を切って干渉を減らす
4. それでも接続できない場合は、ESP32-S3を使用したUSB HID方式への変更を検討

### 文字が正しく入力されない

**現象**: 文字の取りこぼし、文字化け

**対処法**:
1. WebアプリのスライダーでKey Delayを50ms以上に増やす
2. `config.h`の`KEY_DELAY_MS`を大きくする（推奨: 30〜50ms）
3. プチコン4のエディタが開いた状態で送信を開始する

### Webアプリに接続できない

1. ESP32とPCが同じWiFiネットワークにいることを確認
2. シリアルモニタに表示されたIPアドレスをブラウザで開く
3. ファイアウォールがポート80をブロックしていないか確認

## 🔄 代替案（BLEが使えない場合）

Switch 2がBLE HIDキーボードをサポートしない場合、以下の代替案があります:

| 方式 | 必要なハードウェア | 説明 |
|------|-------------------|------|
| USB HID | ESP32-S3 | USB OTG対応のESP32-S3で有線キーボードとして動作 |
| USBドングル方式 | ESP32 + USBホストシールド | 無線キーボードのUSBドングルをエミュレート |

これらの代替実装が必要な場合はお知らせください。

## 📁 ファイル構成

```
DummyKeyboardSW2/
├── DummyKeyboardSW2.ino  # メインスケッチ
├── config.h              # 設定ファイル
└── web_content.h         # WebアプリUI (HTML/CSS/JS)
```

## 🔗 リンク

- [ESP32-BLE-Keyboard](https://github.com/T-vK/ESP32-BLE-Keyboard) - 使用ライブラリ
- [プチコン4](https://www.petc4.smilebasic.com/) - Nintendo Switch向けBASIC環境
- [Arduino ESP32](https://github.com/espressif/arduino-esp32) - ESP32用Arduinoコア

## 📝 ライセンス

MIT License

## 🛠️ 開発情報

- **作成日**: 2025年12月
- **対象デバイス**: Geekcreit® ESP32 30ピン開発ボード
- **対象コンソール**: Nintendo Switch 2（2025年6月リリース）
- **リポジトリ**: https://github.com/t2k2pp/DummyKeyboardSW2
