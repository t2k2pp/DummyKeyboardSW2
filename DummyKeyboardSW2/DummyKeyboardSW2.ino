/*
 * ESP32 Bluetooth Keyboard for Switch 2
 * Dummy Keyboard for Petit Computer 4 (プチコン4)
 * 
 * このスケッチは以下の機能を提供します:
 * - WiFi経由のWebサーバー（PC向けUIを提供）
 * - BLE HIDキーボード（Switch 2にテキストを入力）
 * 
 * 使用ライブラリ:
 * - ESP32-BLE-Keyboard: https://github.com/T-vK/ESP32-BLE-Keyboard
 * 
 * 作者: t2k2pp
 * リポジトリ: https://github.com/t2k2pp/DummyKeyboardSW2
 */

#include <WiFi.h>
#include <WebServer.h>
#include <BleKeyboard.h>
#include "config.h"
#include "web_content.h"

// BLEキーボードインスタンス
BleKeyboard bleKeyboard(BLE_DEVICE_NAME, BLE_MANUFACTURER, BLE_BATTERY_LEVEL);

// Webサーバーインスタンス
WebServer server(WEB_SERVER_PORT);

// 送信状態管理
volatile bool isSending = false;
volatile bool stopRequested = false;
String textBuffer = "";
int currentPosition = 0;
int keyDelayMs = KEY_DELAY_MS;

// 状態LED（オプション: 内蔵LEDがあれば使用）
#define LED_PIN 2

// ===== セットアップ =====
void setup() {
    Serial.begin(115200);
    Serial.println();
    Serial.println("====================================");
    Serial.println(" Switch Keyboard - Starting...");
    Serial.println("====================================");
    
    // LED初期化
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, LOW);
    
    // BLEキーボード開始
    Serial.println("[BLE] Initializing BLE Keyboard...");
    bleKeyboard.begin();
    bleKeyboard.setDelay(keyDelayMs);
    Serial.println("[BLE] BLE Keyboard started: " + String(BLE_DEVICE_NAME));
    
    // WiFi接続
    Serial.println("[WiFi] Connecting to " + String(WIFI_SSID) + "...");
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    
    int wifiTimeout = 0;
    while (WiFi.status() != WL_CONNECTED && wifiTimeout < 30) {
        delay(500);
        Serial.print(".");
        wifiTimeout++;
    }
    
    if (WiFi.status() == WL_CONNECTED) {
        Serial.println();
        Serial.println("[WiFi] Connected!");
        Serial.println("[WiFi] IP Address: " + WiFi.localIP().toString());
    } else {
        Serial.println();
        Serial.println("[WiFi] Connection failed! Starting AP mode...");
        // APモードでフォールバック
        WiFi.softAP("SwitchKeyboard", "12345678");
        Serial.println("[WiFi] AP Mode: SwitchKeyboard / 12345678");
        Serial.println("[WiFi] AP IP: " + WiFi.softAPIP().toString());
    }
    
    // Webサーバールート設定
    server.on("/", HTTP_GET, handleRoot);
    server.on("/send", HTTP_POST, handleSend);
    server.on("/stop", HTTP_POST, handleStop);
    server.on("/status", HTTP_GET, handleStatus);
    server.onNotFound(handleNotFound);
    
    // CORS対応
    server.enableCORS(true);
    
    // サーバー開始
    server.begin();
    Serial.println("[Web] Server started on port " + String(WEB_SERVER_PORT));
    
    Serial.println();
    Serial.println("====================================");
    Serial.println(" Ready! Access: http://" + WiFi.localIP().toString());
    Serial.println("====================================");
    Serial.println();
}

// ===== メインループ =====
void loop() {
    server.handleClient();
    
    // LED点滅: BLE接続状態表示
    static unsigned long lastBlink = 0;
    if (millis() - lastBlink > 1000) {
        lastBlink = millis();
        if (bleKeyboard.isConnected()) {
            digitalWrite(LED_PIN, HIGH);
        } else {
            digitalWrite(LED_PIN, !digitalRead(LED_PIN));
        }
    }
    
    // 非同期テキスト送信
    if (isSending && !stopRequested) {
        processNextCharacter();
    }
    
    delay(1);  // Watchdog対策
}

// ===== Webハンドラー =====

// ルートページ（WebアプリUI）
void handleRoot() {
    server.send(200, "text/html", INDEX_HTML);
}

// テキスト送信リクエスト
void handleSend() {
    if (!server.hasArg("text")) {
        server.send(400, "application/json", "{\"success\":false,\"message\":\"No text provided\"}");
        return;
    }
    
    if (!bleKeyboard.isConnected()) {
        server.send(400, "application/json", "{\"success\":false,\"message\":\"BLE not connected to Switch 2\"}");
        return;
    }
    
    if (isSending) {
        server.send(400, "application/json", "{\"success\":false,\"message\":\"Already sending\"}");
        return;
    }
    
    // テキストを取得
    textBuffer = server.arg("text");
    
    // サイズチェック
    if (textBuffer.length() > MAX_TEXT_SIZE) {
        server.send(400, "application/json", "{\"success\":false,\"message\":\"Text too large (max " + String(MAX_TEXT_SIZE) + " bytes)\"}");
        return;
    }
    
    // 入力速度設定
    if (server.hasArg("delay")) {
        keyDelayMs = server.arg("delay").toInt();
        if (keyDelayMs < 10) keyDelayMs = 10;
        if (keyDelayMs > 500) keyDelayMs = 500;
        bleKeyboard.setDelay(keyDelayMs);
    }
    
    // 送信開始
    currentPosition = 0;
    stopRequested = false;
    isSending = true;
    
    Serial.println("[Send] Starting: " + String(textBuffer.length()) + " chars, delay=" + String(keyDelayMs) + "ms");
    
    // 同期的に送信（短いテキストの場合はすぐ完了）
    while (isSending && !stopRequested && currentPosition < textBuffer.length()) {
        processNextCharacter();
        delay(1);
    }
    
    isSending = false;
    
    if (stopRequested) {
        server.send(200, "application/json", "{\"success\":true,\"message\":\"Stopped at " + String(currentPosition) + " chars\"}");
    } else {
        server.send(200, "application/json", "{\"success\":true,\"message\":\"Completed: " + String(textBuffer.length()) + " chars\"}");
    }
    
    Serial.println("[Send] Finished");
}

// 停止リクエスト
void handleStop() {
    stopRequested = true;
    server.send(200, "application/json", "{\"success\":true,\"message\":\"Stop requested\"}");
    Serial.println("[Send] Stop requested");
}

// 状態取得
void handleStatus() {
    String json = "{";
    json += "\"bleConnected\":" + String(bleKeyboard.isConnected() ? "true" : "false") + ",";
    json += "\"isSending\":" + String(isSending ? "true" : "false") + ",";
    json += "\"progress\":" + String(currentPosition) + ",";
    json += "\"total\":" + String(textBuffer.length()) + ",";
    json += "\"delay\":" + String(keyDelayMs);
    json += "}";
    
    server.send(200, "application/json", json);
}

// 404ハンドラー
void handleNotFound() {
    server.send(404, "text/plain", "Not Found");
}

// ===== テキスト送信処理 =====

void processNextCharacter() {
    if (currentPosition >= textBuffer.length()) {
        isSending = false;
        return;
    }
    
    char c = textBuffer.charAt(currentPosition);
    
    // 改行処理
    if (c == '\n') {
        bleKeyboard.write(KEY_RETURN);
        delay(LINE_END_DELAY_MS);  // 行末は少し長めに待機
    }
    // キャリッジリターンはスキップ（\r\n → \n として処理）
    else if (c == '\r') {
        // 次が\nならスキップ
        if (currentPosition + 1 < textBuffer.length() && textBuffer.charAt(currentPosition + 1) == '\n') {
            // 何もしない
        } else {
            bleKeyboard.write(KEY_RETURN);
            delay(LINE_END_DELAY_MS);
        }
    }
    // タブ
    else if (c == '\t') {
        bleKeyboard.write(KEY_TAB);
        delay(keyDelayMs);
    }
    // 通常文字（ASCII範囲）
    else if (c >= 0x20 && c <= 0x7E) {
        bleKeyboard.print(String(c));
        delay(keyDelayMs);
    }
    // その他（非ASCII）- スキップするか、そのまま送信を試みる
    else if ((uint8_t)c > 0x7E) {
        // 日本語などのマルチバイト文字はそのまま送信を試みる
        // 注意: BLEキーボードはASCIIのみ対応の可能性が高い
        bleKeyboard.print(String(c));
        delay(keyDelayMs);
    }
    
    currentPosition++;
    
    // 進行状況ログ（100文字ごと）
    if (currentPosition % 100 == 0) {
        Serial.println("[Send] Progress: " + String(currentPosition) + "/" + String(textBuffer.length()));
    }
}
