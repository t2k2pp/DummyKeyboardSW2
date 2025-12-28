/*
 * ESP32 Bluetooth Keyboard for Switch 2
 * Configuration File
 * 
 * このファイルでWiFiやBLE設定を行います
 */

#ifndef CONFIG_H
#define CONFIG_H

// ===== WiFi設定 =====
// ご使用のWiFiネットワークに合わせて変更してください
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// ===== BLE Keyboard設定 =====
#define BLE_DEVICE_NAME "Switch Keyboard"
#define BLE_MANUFACTURER "ESP32"
#define BLE_BATTERY_LEVEL 100

// ===== キー入力設定 =====
// キー入力間隔（ミリ秒）- Switch 2が追従できる速度に調整
// 小さいほど高速だが、取りこぼしが発生する可能性あり
#define KEY_DELAY_MS 30

// 行末での待機時間（Enterキー後のディレイ）
#define LINE_END_DELAY_MS 100

// ===== Webサーバー設定 =====
#define WEB_SERVER_PORT 80

// ===== バッファ設定 =====
// 最大テキストサイズ（バイト）
#define MAX_TEXT_SIZE 32768

#endif // CONFIG_H
