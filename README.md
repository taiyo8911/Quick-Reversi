# Quick Reversi
【iOS】対面プレイ対応のシンプルなリバーシ（オセロ）アプリ
1台のスマートフォンを挟んで2人で向かい合って遊べる、洗練されたミニマルデザインのリバーシ。

---

## アプリタイトル

**Quick Reversi**

---

## フォルダ構成

```
Othello/
├── Models/
│   └── OthelloModel.swift          // ゲームのロジックと盤面データの管理
├── ViewModels/
│   └── OthelloViewModel.swift      // モデルとビューの仲介（状態管理）
├── Views/
│   ├── ContentView.swift           // アプリのルートビュー（StartView を表示）
│   ├── StartView.swift             // タイトル画面
│   └── OthelloBoardView.swift      // 盤面表示・タップ処理・スコア・終了オーバーレイ
├── Utilities/
│   └── SoundManager.swift          // 効果音再生（着手音・ゲーム終了音）
└── OthelloApp.swift                // アプリのエントリーポイント（@main）
```

---

## 画面構成

### 1. タイトル画面（`StartView`）
- 深いグリーンのグラデーション背景＋柔らかなトップライト
- オセロを象徴する黒白2枚のディスクモチーフ
- セリフ体のタイトル「Reversi」とサブタイトル "A GAME OF STRATEGY"
- ピル型の「Start Game」ボタンで対局画面へ遷移
- 起動時に段階的フェードインアニメーション

### 2. 対局画面（`OthelloBoardView`）
1台のデバイスを挟んで対面プレイする想定で、UI が**上下にミラー配置**される。

- **背景**: タイトル画面と統一した深いグリーンのグラデーション
- **盤面**: カード状の1枚パネル（角丸＋影＋細いグリッド線）。画面幅に追従
- **石**: フラットなベタ塗りの黒白
- **スコアカード**:
  - 画面**下部**: 黒プレイヤー側のスコアカード（手前のプレイヤー向き）
  - 画面**上部**: 白プレイヤー側のスコアカード（180°回転、対面プレイヤー向き）
  - 現在の手番のカードに白枠＋スケールアップで視覚的にハイライト
- **着手音**: 石を置くたびに効果音を再生（`SoundManager.playCorrectSound`）

### 3. ゲーム終了オーバーレイ
- 半透明の黒スクリムで盤面を暗転
- 「Black Wins」/「White Wins」/「Draw」を表示する結果カードを**上下2枚スタック**
- 両プレイヤーから正立して読めるよう、上のカードは180°回転
- 各カードに「Play Again」ボタン（どちらからでもタップ可能）
- ゲーム終了時に効果音を再生（`SoundManager.playGameOverSound`）

---

## ゲームシステム

### 🟢 1. ゲームの開始
- アプリ起動時、`OthelloApp` → `ContentView` → `StartView` の順で表示される
- 「Start Game」ボタンタップで `OthelloBoardView` を `fullScreenCover` 表示
- `OthelloModel` の `init()` で 8×8 の盤面が初期化され、中央の4マスに初期配置の石が置かれる
- 最初の手番は `currentPlayer = .black`（黒が先手）

### ⚫ 2. プレイヤーが石を置く
- プレイヤーが空きマスをタップ → `OthelloBoardView` の `.onTapGesture` が検知
- `OthelloViewModel.placeStone(row:col:)` を経由して `OthelloModel.placeStone` が実行される

`OthelloModel` 内の処理:
1. **空チェック** — 既に石があるマスは無視
2. **有効手の確認** — `isValidMove()` で8方向に相手の石を挟めるか判定
3. **石の配置とひっくり返し** — `flipStones()` で挟んだ相手の石をすべて自分の色に反転
4. **手番の交代** — 次プレイヤーに有効な手がない場合は自動でパス（手番が戻る）

着手成功時には `SoundManager.playCorrectSound()` が呼ばれる。

### ⚪ 3. 手番の進行
- `@Published` プロパティの更新により、スコアカードのハイライトが手番側に自動で切り替わる
- 黒と白が交互に石を置く
- 有効な手がないプレイヤーはパスされ、相手が連続で打つ

### 🛑 4. ゲームの終了
**終了条件**: 両プレイヤーとも合法的に石を置ける場所がなくなった場合（`isGameOver()`）

**勝敗判定**: `stoneCounts()` で黒・白の石を集計し、多い方が勝ち。同数なら引き分け。

**結果表示**: ゲーム終了オーバーレイが上下ミラーで表示され、勝者名・最終スコア・「Play Again」ボタンが両プレイヤーから読める。

---

## デザイン方針

- **配色**: 盤面の深いグリーンを基調とし、石の黒白とアクセントの白で構成
- **タイポグラフィ**: タイトルはセリフ体、スコアは丸ゴシック体（`monospacedDigit`）
- **石のスタイル**: フラットなベタ塗り（立体的なグラデやハイライトは使わない）
- **アニメーション**: スプリング系の控えめなトランジションで手番切り替えやオーバーレイ表示を演出

---

## 技術スタック

- **言語**: Swift
- **UI フレームワーク**: SwiftUI
- **アーキテクチャ**: MVVM（Model / ViewModel / View）
- **状態管理**: `@Published` + `ObservableObject`
- **効果音**: `AudioToolbox` の `AudioServicesPlaySystemSound`

