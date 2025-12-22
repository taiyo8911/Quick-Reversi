//
//  OthelloViewModel.swift
//  Othello
//
//  Created by Taiyo KOSHIBA on 2025/02/10.
//



import SwiftUI

/// オセロゲームの状態を管理する ViewModel
class OthelloViewModel: ObservableObject {
    @Published private(set) var model = OthelloModel()    // ゲームのロジックとデータを持つモデル
    @Published var isGameOver = false                       // ゲーム終了を示すフラグ
    @Published var gameOverText: String = ""                // ゲーム終了時のメッセージ（勝敗＋カウント）

    /// 盤面の状態を返すプロパティ（ビューから参照）
    var board: [[Stone]] {
        model.board
    }

    /// 現在のプレイヤーを返すプロパティ
    var currentPlayer: Stone {
        model.currentPlayer
    }

    /// 指定した位置に石を置く。成功すれば盤面を更新し、ゲーム終了判定も行う
    func placeStone(row: Int, col: Int) {
        if model.placeStone(row: row, col: col) {
            // 石を置いた後、ゲーム終了かどうかチェック
            if model.isGameOver() {
                let counts = model.stoneCounts()
                // 勝敗とカウントを含むメッセージを作成
                if counts.black > counts.white {
                    gameOverText = "黒の勝ち！ (黒: \(counts.black), 白: \(counts.white))"
                } else if counts.white > counts.black {
                    gameOverText = "白の勝ち！ (黒: \(counts.black), 白: \(counts.white))"
                } else {
                    gameOverText = "引き分け！ (黒: \(counts.black), 白: \(counts.white))"
                }
                isGameOver = true
                SoundManager.playGameOverSound()
            }
            objectWillChange.send()
        }
    }
    
    /// ゲームの状態を初期化してリセットするメソッド
    func resetGame() {
        model = OthelloModel()  // 新しいモデルで初期化
        isGameOver = false
        gameOverText = ""
        objectWillChange.send()
    }
}

