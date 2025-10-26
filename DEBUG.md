# ScanSnapper デバッグログ

## 2025-10-25 09:16 - 初回起動時の問題

### 症状
- ✅ アプリは起動している（Running状態）
- ❌ メニューバーアイコンが表示されない
- ❌ QRコード読み込みに反応しない
- ❌ コンソールに何も出力されない
- ⚠️ Build に警告マークあり

### 考えられる原因
1. **ビルドエラー/警告**: Build に警告マークがあるため、コンパイルに問題がある可能性
2. **ORSSerialPort未解決**: Swift Package が正しくリンクされていない
3. **Info.plist設定**: LSUIElement設定やその他の権限が不足
4. **シリアルポート権限**: macOSのセキュリティ設定でシリアルポートアクセスが拒否されている
5. **AppDelegate未実行**: applicationDidFinishLaunching が呼ばれていない

### 調査手順
- [x] Xcodeのビルドログを確認 → ビルド成功
- [x] Issue Navigatorで警告/エラーを確認 → 3つの警告を修正
- [x] ORSSerialPort パッケージの解決状態を確認 → 正常に解決済み
- [x] AppDelegate に詳細なログを追加 → 追加済み
- [x] コンソール出力が表示されるか確認 → **表示されない**

### 根本原因を発見！

**AppDelegate の @main が実行されていない**

- プロセスは起動している (ps で確認済み)
- しかし `applicationDidFinishLaunching` が呼ばれていない
- Info.plist に `NSMainStoryboardFile` が空で設定されていた
- Xcodeプロジェクト設定に Main Interface が設定されていた可能性

### 実施した修正
1. ✅ ビルド警告の修正:
   - `error` → `scanError` に変更 (未使用変数警告)
   - 非推奨の `NSUserNotification` を削除
   - `AccentColor.colorset` を追加

2. ✅ デバッグログの追加:
   - `applicationDidFinishLaunching` に詳細ログ追加
   - `setupMenuBar` に詳細ログ追加

3. ✅ Info.plist の修正:
   - `NSMainStoryboardFile` エントリを削除

4. ✅ Xcodeプロジェクト設定の修正:
   - `INFOPLIST_KEY_NSMainNibFile` を削除
   - `INFOPLIST_KEY_NSMainStoryboardFile` を削除
   - `fix_project_settings.rb` で自動修正

## 2025-10-25 09:32 - ✅ 問題解決！

### 根本原因
**@main だけではAppDelegateが起動しない**

SwiftでAppKitアプリを作る場合、以下のいずれかが必要:
1. `@NSApplicationMain` 属性（古い方法、Swift 5.3以前）
2. `@main` 属性 + SwiftUI App構造
3. **main.swift でアプリを明示的にブートストラップ（推奨）**

### 最終的な解決策

**main.swift を作成**してAppDelegateを明示的に起動:

```swift
import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
```

**AppDelegate.swift から @main を削除**:
```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    // @main を削除
```

### 動作確認
```
✅ Application launching
✅ Status item created
✅ Button title set to 📱
✅ Menu bar setup complete
✅ Found 1 USB modem ports: /dev/cu.usbmodemW2306054321
✅✅✅ Application launched successfully
```

## 2025-10-25 09:45 - メニューバーアイコン表示問題を修正

### 問題
- アプリは起動するがメニューバーアイコンが表示されない
- QRコードを読んでもデータが受信されない（ポートが開いていない）

### 原因
1. **main.swift で `.accessory` を早すぎるタイミングで呼んでいた**
2. **NSStatusItem.isVisible が明示的に設定されていなかった**
3. **シリアルポートが自動で開かれていなかった**

### 修正内容
1. ✅ main.swift から `.setActivationPolicy(.accessory)` を削除（LSUIElement で十分）
2. ✅ AppDelegate で `statusItem.isVisible = true` を明示的に設定
3. ✅ 最初のシリアルポートを自動選択・自動オープン (9600 baud)

## 2025-10-25 09:50 - シリアルポート "Resource busy" エラー修正

### 問題
- シリアルポートを開こうとすると "Resource busy" エラー
- 既に `screen` プロセス (PID 1321) がポートを使用していた

### 修正
```bash
kill 1321  # screen プロセスを終了
```

### メニューバーアイコン改善
- **絵文字 (📱) から SF Symbol に変更**
- `qrcode.viewfinder` SF Symbol を使用（macOS標準アイコン）
- `isTemplate = true` で Dark Mode 対応

## 2025-10-25 09:57 - メニューバーアイコン表示の根本原因を特定・修正

### 根本原因の分析 (UltraThink)

**問題**: NSStatusItem が作成され、ログでは全て成功しているのにメニューバーに表示されない

**調査結果**:
1. Stack Overflow と Apple ドキュメントを徹底調査
2. LSUIElement=true だけでは不十分
3. **決定的な問題**: `NSApp.setActivationPolicy(.accessory)` が呼ばれていなかった

### 根本原因
macOS では、**LSUIElement** (Info.plist) と **Activation Policy** (コード) の両方が必要：
- **LSUIElement**: アプリを "Agent" として宣言
- **setActivationPolicy(.accessory)**: ランタイムでDockアイコンを非表示にし、メニューバーアイテムを有効化

### 実施した修正

#### 1. ✅ Activation Policy の追加
```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    // CRITICAL: これがないとメニューバーアイコンが表示されない！
    NSApp.setActivationPolicy(.accessory)

    // その後にステータスアイテムを作成
    setupMenuBar()
}
```

#### 2. ✅ ボタンの簡素化
- SF Symbol から **シンプルなテキスト "QR"** に変更
- 最大互換性のため、複雑なグラフィックを避ける

#### 3. ✅ 明示的な表示制御
```swift
statusItem.isVisible = true
statusItem.button?.isEnabled = true
statusItem.button?.needsDisplay = true
```

#### 4. ✅ メニュー設定の最適化
```swift
menu.autoenablesItems = false  // 手動制御
```

### なぜこれが重要か

**Stack Overflow からの引用**:
> "The modern approach is using `NSApp.setActivationPolicy(.prohibited)` or `.accessory`.
> LSUIElement alone is not enough on modern macOS."

**macOS の動作**:
- LSUIElement=true: システムに「これはバックグラウンドアプリです」と伝える
- setActivationPolicy(.accessory): ランタイムで「Dockアイコンなし、メニューバーアイテムあり」を実現

## 2025-10-26 10:32 - ペースト機能が動作しない問題を修正

### 症状
- ✅ メニューバーアイコン表示成功
- ✅ QRコードデータ受信成功
- ❌ データがペーストされない

### ログ分析
```
[SerialManager] Received normalized data: S:


O:
40

A:
[PasteService] WARNING: Accessibility permissions not granted. Text output may fail.
```

データは受信できているが、その後 `handlePasteMode` のログが一切ない。

### 根本原因発見

**PasteService.swift:25-28 の致命的なバグ**:
```swift
guard AXIsProcessTrusted() else {
    NSLog("[PasteService] WARNING: ...")
    return  // ← ここで処理が止まっている！
}
```

**問題**:
- Paste mode は **アクセシビリティ権限が不要** (クリップボード + Cmd+V シミュレーション)
- しかしコードは権限チェックで `return` していた
- そのため `handlePasteMode` が一度も呼ばれていなかった

### 修正内容

```swift
// 修正前: 全モードで権限チェックして return
guard AXIsProcessTrusted() else {
    return  // ← Paste mode も止まる！
}

// 修正後: Type mode のみ権限チェック
let hasAccessibility = AXIsProcessTrusted()
if !hasAccessibility {
    if outputMode == .type {
        NSLog("ERROR: Type mode requires accessibility. Aborting.")
        return  // ← Type mode だけ止める
    } else {
        NSLog("INFO: Paste mode will attempt to work without accessibility.")
        // ← Paste mode は続行
    }
}
```

### なぜこれが重要か

**Paste mode の仕組み**:
1. テキストをクリップボードにコピー (`NSPasteboard`) ← 権限不要
2. Cmd+V を CGEvent でシミュレート ← 権限不要
3. アクティブなアプリにペースト

**Type mode の仕組み**:
1. 各文字を CGEvent でキー入力シミュレート ← **権限必須**

## 2025-10-26 10:50 - 日本語（Unicode）文字が削除される問題を修正

### 症状
- ✅ QRコード読み取り成功
- ✅ ペースト機能動作
- ❌ 日本語が表示されない（文字化け）

### ログ分析
```
[SerialManager] Received normalized data: S:


O:
40

A:
```

日本語部分が完全に削除されている。おそらく元データは「SOAP40A」などの日本語だったはず。

### 根本原因

**SerialManager.swift:135 の normalizeText() 関数**:
```swift
// 修正前: ASCII範囲（32-126）のみ保持
if value >= 32 && value <= 126 {
    result.append(Character(scalar))
}
// → 日本語（Unicodeコード > 127）が全て削除される！
```

**問題**:
- 元のコードは制御文字を除去するため、ASCII範囲のみを保持
- しかし日本語（ひらがな、カタカナ、漢字）は **Unicode 127以上**
- そのため全ての日本語が削除されていた

### 修正内容

```swift
// 修正後: Unicode文字を保持
if value == 9 || value == 10 {
    result.append(Character(scalar))  // TAB, LF
} else if value == 13 {
    result.append("\n")  // CR → LF
} else if (value >= 32 && value <= 126) || value > 127 {
    result.append(Character(scalar))
    // ↑ ASCII (32-126) または Unicode (> 127) を保持
}
// 有害な制御文字 (0-8, 11-12, 14-31) のみ除去
```

### Unicode範囲の説明

| 文字種 | Unicode範囲 | 例 |
|--------|------------|-----|
| ASCII制御文字 | 0-31 | NULL, ESC, DEL |
| ASCII印字可能 | 32-126 | A-Z, a-z, 0-9, 記号 |
| 拡張ASCII | 127 | DEL |
| **日本語** | **> 127** | **あいうえお、アイウエオ、漢字** |

### なぜこれが重要か

QRコードには日本語が含まれることが多い：
- 商品名: 「石鹸40A」
- 住所: 「東京都」
- 名前: 「山田太郎」

これらを正しく処理するには、**Unicode全体をサポート**する必要があります。

## 2025-10-26 11:05 - 自動ペーストが動作しない問題を修正

### 症状
- ✅ クリップボードにコピー成功
- ❌ カーソル位置に自動ペーストされない
- ログには「Cmd+V synthesized successfully」と表示されるが、実際にはペーストされない

### 根本原因

**macOS Mojave (10.14) 以降の重要な仕様変更**:
- **CGEvent でキーストロークを送信するには、必ずアクセシビリティ権限が必要**
- 権限がない場合、CGEvent は作成できるが、システムに届かない
- `AXIsProcessTrusted()` が `false` を返している

### 調査結果

**Stack Overflow / Apple Developer Forums より**:
> "Starting with macOS Mojave (10.14), Apple changed the default system permissions
> for using CGEventTaps and CGEvent posting to require explicit user permission in
> System Preferences > Security & Privacy > Privacy > Accessibility."

**重要**:
- Paste mode も **Cmd+V のシミュレーション** を使うため、アクセシビリティ権限が必須
- クリップボードへのコピーは権限不要
- キーストロークの送信には権限必須

### 実施した修正

#### 1. ✅ 明示的な権限チェックとユーザーガイダンス
```swift
if !hasAccessibility {
    // 親切なアラート表示
    alert.messageText = "アクセシビリティ権限が必要です"
    alert.informativeText = "テキストはクリップボードにコピー済みです。\n手動で Cmd+V を押してペーストするか、システム設定で権限を許可してください。"
    // システム設定へのリンク提供
}
```

#### 2. ✅ CGEvent の投稿先を変更
```swift
// 修正前
cmdDown.post(tap: .cgSessionEventTap)

// 修正後 (より確実)
cmdDown.post(tap: .cghidEventTap)
```

#### 3. ✅ イベント間に遅延追加
```swift
Thread.sleep(forTimeInterval: 0.05)  // クリップボード準備
Thread.sleep(forTimeInterval: 0.01)  // キーイベント間
```

#### 4. ✅ 詳細なログ出力
各ステップで成功/失敗をログに記録

### アクセシビリティ権限の有効化手順

1. **システム設定を開く**
   - Apple メニュー > システム設定

2. **プライバシーとセキュリティ**
   - 左メニューから「プライバシーとセキュリティ」を選択

3. **アクセシビリティ**
   - 右側のリストから「アクセシビリティ」をクリック

4. **ScanSnapper を追加**
   - 「+」ボタンをクリック
   - アプリケーション > ScanSnapper.app を選択
   - チェックボックスをONにする

5. **アプリを再起動**
   - ScanSnapper を終了して再起動

### 権限が有効な場合のログ
```
[PasteService] Accessibility permission status: true
[PasteService] Posted Cmd down
[PasteService] Posted V down
[PasteService] Posted V up
[PasteService] Posted Cmd up
[PasteService] ✅ Cmd+V synthesized and posted successfully
```

### 次のステップ
1. ~~メニューバーアイコン表示~~
2. ~~QRコード読み取り~~
3. ~~日本語サポート~~
4. ~~クリップボードコピー~~
5. **アクセシビリティ権限を有効化**
6. **自動ペーストをテスト**

---

## ビルド情報
- Xcode Project: ScanSnapper.xcodeproj
- Target: ScanSnapper
- Platform: macOS 12.0+
- Swift Version: 5.0
- Package Dependencies: ORSSerialPort 2.1.0

## ファイル構成
```
ScanSnapper_for_mac/
├── Sources/
│   ├── AppDelegate.swift
│   ├── SerialManager.swift
│   ├── PasteService.swift
│   ├── Info.plist
│   └── Assets.xcassets/
└── ScanSnapper.xcodeproj/
```
