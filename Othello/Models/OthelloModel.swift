//
//  OthelloModel.swift
//  Othello
//
//  Created by Taiyo KOSHIBA on 2025/02/10.
//


import Foundation

// MARK: - 石の種類を表す列挙型
enum Stone {
    case empty    // 空のマス（何も置かれていない）
    case black    // 黒石
    case white    // 白石
    
    // 自分の石の反対の色を返す
    var opposite: Stone {
        switch self {
        case .black:
            return .white
        case .white:
            return .black
        case .empty:
            return .empty
        }
    }
}

// MARK: - オセロのゲームロジックを管理するモデル
struct OthelloModel {
    let size = 8  // 盤面のサイズ（8x8）
    var board: [[Stone]]  // 盤面の状態（2次元配列）
    var currentPlayer: Stone = .black  // 現在のプレイヤー（黒が先手）

    // MARK: - ① 初期化処理（中央に4つの石を配置する）
    init() {
        board = Array(repeating: Array(repeating: .empty, count: size), count: size)
        board[3][3] = .white
        board[3][4] = .black
        board[4][3] = .black
        board[4][4] = .white
    }

    // MARK: - ② 石を置く処理
    // 指定した位置に現在のプレイヤーの石を置く
    // - 成功すれば `true` を返し、失敗（置けない場合）は `false` を返す
    mutating func placeStone(row: Int, col: Int) -> Bool {
        // すでに石がある、または有効な手でない場合は置けない
        if board[row][col] != .empty || !isValidMove(row: row, col: col) {
            return false
        }
        // 石を配置
        board[row][col] = currentPlayer
        // 効果音を再生
        SoundManager.playCorrectSound()
        // 挟んだ相手の石をひっくり返す
        flipStones(row: row, col: col)
        // プレイヤーを交代
        toggleTurn()
        return true
    }

    // MARK: - ③ 石を置けるか判定する処理
    // 指定した位置に石を置くことが可能かチェックする
    private func isValidMove(row: Int, col: Int) -> Bool {
        let directions = [(-1, -1), (-1, 0), (-1, 1), // 上3方向
                          (0, -1),          (0, 1),  // 左右
                          (1, -1),  (1, 0), (1, 1)] // 下3方向
        // どれかの方向で相手の石を挟めるなら有効な手
        return directions.contains { canFlip(row: row, col: col, direction: $0) }
    }

    // ある方向に進んで、相手の石を挟めるか判定
    private func canFlip(row: Int, col: Int, direction: (Int, Int)) -> Bool {
        var r = row + direction.0
        var c = col + direction.1
        var foundOpponent = false // 最初に相手の石を見つけたかどうか

        while r >= 0 && r < size && c >= 0 && c < size {
            if board[r][c] == currentPlayer {
                // 自分の石に到達し、その間に相手の石があればOK
                return foundOpponent
            } else if board[r][c] == .empty {
                // 空のマスに当たったら挟めない
                return false
            }
            // 相手の石を発見
            foundOpponent = true
            r += direction.0
            c += direction.1
        }
        return false
    }

    // MARK: - ④ 挟んだ石をひっくり返す処理
    // 指定した位置から8方向に相手の石をひっくり返す
    private mutating func flipStones(row: Int, col: Int) {
        let directions = [(-1, -1), (-1, 0), (-1, 1),
                          (0, -1),          (0, 1),
                          (1, -1),  (1, 0), (1, 1)]
        for direction in directions {
            if canFlip(row: row, col: col, direction: direction) {
                var r = row + direction.0
                var c = col + direction.1
                // 挟んでいる相手の石を自分の石に変える
                while board[r][c] != currentPlayer {
                    board[r][c] = currentPlayer
                    r += direction.0
                    c += direction.1
                }
            }
        }
    }

    // MARK: - ⑤ 手番を交代する処理
    // 現在のプレイヤーを交代する
    // - ただし、次のプレイヤーが打てる手がない場合はスキップする
    private mutating func toggleTurn() {
        currentPlayer = currentPlayer.opposite
        if !hasValidMove(for: currentPlayer) {
            currentPlayer = currentPlayer.opposite
        }
    }

    // MARK: - ⑥ ゲーム終了判定
    // 指定したプレイヤーが有効な手を持っているか判定
    func hasValidMove(for player: Stone) -> Bool {
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] == .empty && isValidMove(row: row, col: col) {
                    return true
                }
            }
        }
        return false
    }

    // 両プレイヤーに有効な手がなければゲーム終了
    func isGameOver() -> Bool {
        return !hasValidMove(for: .black) && !hasValidMove(for: .white)
    }

    // MARK: - ⑦ 石の数をカウント
    // 盤面上の黒石と白石の数をカウントする
    func stoneCounts() -> (black: Int, white: Int) {
        var blackCount = 0
        var whiteCount = 0
        for row in board {
            for stone in row {
                if stone == .black {
                    blackCount += 1
                } else if stone == .white {
                    whiteCount += 1
                }
            }
        }
        return (blackCount, whiteCount)
    }
}
