# ScanSnapper 要件定義

## 1) ゴール

* USB接続のBC-NL3000UII（**USB-COM/CDC-ACM**）で受信した**日本語テキスト**を、**バックグラウンド常駐**のMacアプリ（Swift）で受け取り、**LF統一→前面アプリへ自動貼付（Cmd+V）**。必要に応じて**タイプ送出**にも切替可能。

## 2) 機能要件（必須）

* **受信ポート**：`/dev/cu.usbmodemWXXXXXXXX`（**/dev/cu.*** を使用）
* **エンコード**：UTF-8固定（QR生成もUTF-8）
* **改行正規化**：`CRLF`/`CR` → **LF** に統一
* **出力方式**：
  ① **Paste**：`NSPasteboard` に文字列→**Cmd+V**送出
  ② **Type**：1文字ずつ**CGEvent**で打鍵（切替可能）
* **サフィックス**：`none` / `Tab` / `Enter`（設定で選択）
* **連結QR/チャンク対応**：**静寂タイムアウト 200ms** で1メッセージ確定
* **取りこぼし対策**：タイプ送出時は**インタバイト遅延 5–10ms** 可
* **IME依存なし**：確定済みテキストを送る前提（IMEは原則OFF想定）

## 3) 非機能要件

* **OS**：macOS 12+（Intel/Apple Silicon）
* **常駐**：メニューバーアイコン、ログイン時自動起動（後日）
* **権限**：アクセシビリティ（キーボード送出）必須
* **配布**：Developer ID 署名＋公証（社内配布でOK）
* **ログ**：既定OFF（オプションで時刻/文字数のみ。本文は保持しない）

## 4) デバイス前提・設定

* スキャナは**USB-COMモード**へ切替（設定QR）
* サフィックスは**なし** or **LF**（アプリ側で統一）
* フロー制御：**未使用**（XON/XOFF, RTS/CTSともOFF想定）
* DTR/RTS：**アプリ側でAssert**（open後に DTR/RTS を立てる）

## 5) アーキテクチャ/技術選定

* **言語/フレーム**：Swift（AppKit）
* **シリアルI/O**：**ORSSerialPort**（SPM導入）
* **主要処理**：
  1. `ORSSerialPort` で `/dev/cu.…` を **open(DTR/RTS ON)**
  2. `didReceive data` でバッファリング
  3. **200ms** 無受信でメッセ確定
  4. **制御文字除去**（TAB/LFと可視のみ許容）
  5. **改行統一（LF）** → **Paste or Type**
  6. 必要に応じ**Tab/Enter**送出

## 6) UI/設定項目

* メニューバー：
  * Port（テキスト or ドロップダウン）
  * Mode：**Paste / Type**
  * Suffix：**none / Tab / Enter**
  * Inter-char Delay（ms）：**0 / 5 / 10**
  * "Append trailing LF"：**on/off**
  * Open / Close / Quit

## 7) エラーハンドリング

* **Port占有/不在**：メニューに状態表示（Open失敗時はリトライ案内）
* **切断**：`serialPortWasRemovedFromSystem` で自動Close
* **受信不可**：DTR/RTS・フロー制御を再適用→警告
* **貼付け不可**：アクセシビリティ未許可を検知→案内ダイアログ

## 8) セキュリティ/プライバシ

* 既定で**本文ログなし**
* 送出は**ローカルのみ**（ネットワーク通信なし）
* 権限は**アクセシビリティ**のみに限定

## 9) テスト計画（受け入れ基準）

* **受信確認**：`screen -U /dev/cu.… 9600` で日本語表示可
* **改行**：`CRLF`入りQR→**LFに統一されて貼付**される
* **長文**：2,000字相当の連結QR→**取りこぼしなし**
* **アプリ互換**：メモ、Chrome、Numbers/Excel、EHR画面（貼付可）で**崩れなし**
* **貼付NG画面**：Paste→失敗、Type模式に切替で**投入成功**
* **遅延効果**：遅延0/5/10msで**落字/詰まりが消える**こと

## 10) Cursorでの実装ガイド（骨組み）

* **Packages**：`https://github.com/armadsen/ORSSerialPort` を SPM追加
* **主要ファイル**：
  * `AppDelegate.swift`：メニューバー、権限チェック、`SerialManager` 起動
  * `SerialManager.swift`：open/受信/タイムアウト確定/正規化/送出
  * `PasteService.swift`：`NSPasteboard` と **CGEvent**（Cmd+V/Tab/Enter/タイプ送出）
* **定数**：
  * `serialPortPath`（初期値：`/dev/cu.usbmodemW2306054321`）
  * `messageCloseInterval = 0.20`
  * `interCharDelayMs = 0/5/10`

## 11) 既知の落とし穴（予防）

* **/dev/tty.* を使うな**（**/dev/cu.*** を使う）
* **アクセシビリティ未許可**でキー送出失敗
* **HIDモードのまま**→COMとしては無反応
* **IME ON**で目的アプリが勝手に変換→**IMEはOFF**運用

## 12) Doneの定義（受領条件）

* 常駐起動中、任意の編集可能フィールドに対し、**QR1回→テキストが即貼付**
* 改行は**LF**で統一される
* **Tab/Enter**の自動付加が選べる
* 貼付不可画面でも**Type**へ切替で投入可能
* ログオフ/再起動後も**自動起動**（将来ON時）で同動作

――以上。この仕様どおりに組め。問題が出たら**発生箇所と現象1行**で返せ。
