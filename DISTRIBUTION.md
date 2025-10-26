# ScanSnapper 配布要件整理

## 📋 配布方法の選択肢

### 1. 簡易配布（個人・組織内）⭐️ 推奨
**対象**: 信頼できる特定ユーザー、社内配布
**必要なもの**: 無料
**手順**: シンプル

### 2. App Store配布
**対象**: 一般ユーザー向け大規模配布
**必要なもの**: Apple Developer Program ($99/年)
**手順**: 複雑

### 3. 公証付き配布
**対象**: 不特定多数への配布（App Store以外）
**必要なもの**: Apple Developer Program ($99/年)
**手順**: 中程度の複雑さ

---

## 🎯 推奨: 簡易配布方法

### 現在の状況
- ✅ ビルド可能なXcodeプロジェクト
- ✅ Release版ビルド可能
- ❌ コード署名なし（Ad-hoc署名のみ）
- ❌ 公証なし

### 配布手順

#### ステップ1: Release版をビルド
```bash
xcodebuild -project ScanSnapper.xcodeproj \
  -scheme ScanSnapper \
  -configuration Release \
  clean archive \
  -archivePath ./build/ScanSnapper.xcarchive
```

#### ステップ2: .appファイルを配布
```bash
# 配布用フォルダ作成
mkdir -p ScanSnapper_v1.0
cp -r build/ScanSnapper.xcarchive/Products/Applications/ScanSnapper.app \
     ScanSnapper_v1.0/

# README追加
cp INSTALLATION.md ScanSnapper_v1.0/

# ZIP圧縮
zip -r ScanSnapper_v1.0.zip ScanSnapper_v1.0/
```

#### ステップ3: 配布
- ZIPファイルをメール、Dropbox、Google Driveなどで共有
- GitHubのReleaseページにアップロード

### ⚠️ 受信者側での注意事項

**初回起動時の手順**:

1. ZIPを解凍
2. `ScanSnapper.app` を **アプリケーションフォルダ** にコピー
3. 初回起動時、以下のエラーが表示される:
   ```
   "ScanSnapper" は開発元が未確認のため開けません。
   ```
4. **回避方法**:
   - **方法A**: アプリを右クリック → 「開く」 → 「開く」
   - **方法B**: システム設定 → プライバシーとセキュリティ → 「このまま開く」

5. アクセシビリティ権限を許可:
   - 起動時にダイアログが表示される
   - システム設定 → プライバシーとセキュリティ → アクセシビリティ
   - ScanSnapper にチェックを入れる

---

## 🔐 コード署名版配布（有料）

### 必要なもの
1. **Apple Developer Program** 登録 ($99/年)
2. **Developer ID Application証明書**
3. **公証（Notarization）**

### メリット
- ✅ ユーザーが右クリック不要で起動可能
- ✅ "安全でない"警告が出ない
- ✅ 自動アップデート機能の実装が可能
- ✅ プロフェッショナルな印象

### デメリット
- ❌ 年間$99のコスト
- ❌ セットアップに時間がかかる（1-2時間）
- ❌ 毎回ビルド時に署名・公証が必要（5-10分）

### 手順概要
1. Apple Developer Programに登録
2. Xcodeで証明書を取得
3. プロジェクトにTeamを設定
4. ビルド
5. 公証（notarytool）
6. DMGまたはZIPで配布

---

## 📦 App Store配布（最も複雑）

### 必要なもの
1. Apple Developer Program ($99/年)
2. App Store Connect セットアップ
3. アプリレビュー通過（1-3日）
4. スクリーンショット、説明文など

### メリット
- ✅ 最も安全で信頼性が高い
- ✅ 自動アップデート
- ✅ 幅広いユーザーに配布可能
- ✅ アプリ内課金可能

### デメリット
- ❌ レビュープロセスが厳しい
- ❌ シリアルポートアクセスの許可が必要（特別なEntitlement）
- ❌ 初回申請に時間がかかる（1週間程度）
- ❌ Appleのガイドライン遵守が必須

---

## 🎯 推奨フロー（段階的）

### フェーズ1: 内部テスト（現在）
- **方法**: Ad-hoc署名のZIP配布
- **対象**: 5-10人程度
- **コスト**: 無料
- **期間**: 即時

### フェーズ2: 限定配布（必要に応じて）
- **方法**: Developer ID署名 + 公証
- **対象**: 50-100人程度
- **コスト**: $99/年
- **期間**: 初回セットアップ1日、以降即時

### フェーズ3: 一般配布（将来的）
- **方法**: App Store
- **対象**: 不特定多数
- **コスト**: $99/年 + メンテナンス時間
- **期間**: 初回申請1週間、アップデート1-3日

---

## 📝 現時点での推奨事項

### すぐに実行すべきこと

1. **INSTALLATION.md 作成** ✅
   - ユーザー向けインストール手順
   - 初回起動時の"開発元未確認"エラーの対処法
   - アクセシビリティ権限の設定方法

2. **Release Build Script 作成** ✅
   - ワンコマンドでZIP作成
   - バージョン番号の自動更新

3. **GitHub Release 作成** ✅
   - ZIPをアップロード
   - リリースノート記載

### 将来的に検討すべきこと

4. **Apple Developer Program 登録**
   - 配布人数が10人以上になったら
   - または"プロフェッショナル"な配布が必要になったら

5. **公証の実装**
   - Developer ID証明書取得
   - notarytool統合

6. **自動アップデート機能**
   - Sparkle framework統合
   - GitHub Releasesと連携

---

## ⚡ 即座に配布可能にする手順

### 今すぐ実行（5分）

```bash
# 1. Release版ビルド
./build_release.sh

# 2. GitHub Releaseを作成
gh release create v1.0.0 \
  --title "ScanSnapper v1.0.0" \
  --notes "初回リリース" \
  ScanSnapper_v1.0.0.zip
```

### ユーザーへの案内

```
ScanSnapper v1.0.0 をダウンロード:
https://github.com/NikoToRA/ScanSnapper_for_mac/releases/latest

インストール方法:
1. ZIPをダウンロードして解凍
2. ScanSnapper.appをアプリケーションフォルダにコピー
3. 右クリック → 「開く」で起動
4. アクセシビリティ権限を許可

詳細: https://github.com/NikoToRA/ScanSnapper_for_mac/blob/main/INSTALLATION.md
```

---

## 🆚 配布方法比較表

| 項目 | Ad-hoc配布 | 公証付き配布 | App Store |
|------|-----------|------------|-----------|
| **コスト** | 無料 | $99/年 | $99/年 |
| **セットアップ時間** | 5分 | 2時間 | 1週間 |
| **ユーザー体験** | 右クリック必要 | スムーズ | 最高 |
| **配布規模** | 小規模 | 中規模 | 大規模 |
| **信頼性** | 低 | 高 | 最高 |
| **アップデート** | 手動 | 半自動 | 自動 |

---

## 💡 結論

**現時点では Ad-hoc配布（無料）で十分です。**

必要に応じて段階的にアップグレード:
1. 🟢 Ad-hoc → 5-10人まで
2. 🟡 公証付き → 50人以上、またはプロフェッショナルな配布が必要
3. 🔴 App Store → 一般公開、大規模配布

次のステップ: リリーススクリプトとインストール手順書を作成しましょう。
