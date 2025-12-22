//
//  OthelloBoardView.swift
//  Othello
//
//  Created by Taiyo KOSHIBA on 2025/02/10.
//


import SwiftUI

struct OthelloBoardView: View {
    @ObservedObject var viewModel: OthelloViewModel
    let size = 8
    
    var body: some View {
        VStack(spacing: 0) {
            // 上部：黒プレイヤー用の手番表示（180度回転）
            Text("⚫")
                .font(viewModel.currentPlayer == .black && !viewModel.isGameOver ? .system(size: 40, weight: .bold) : .system(size: 32))
                .opacity(viewModel.currentPlayer == .black && !viewModel.isGameOver ? 1.0 : 0.3)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .rotationEffect(.degrees(180))

            Spacer()

            // 中央：盤面の表示
            VStack(spacing: 0) {
                ForEach(0..<size, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<size, id: \.self) { col in
                            CellView(stone: viewModel.board[row][col])
                                .onTapGesture {
                                    viewModel.placeStone(row: row, col: col)
                                }
                        }
                    }
                }
            }

            Spacer()

            // ゲーム終了時のメッセージとボタン
            if viewModel.isGameOver {
                VStack(spacing: 10) {
                    Text(viewModel.gameOverText)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("もう一度あそぶ") {
                        viewModel.resetGame()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.vertical, 20)
            } else {
                // 下部：白プレイヤー用の手番表示
                Text("⚪")
                    .font(viewModel.currentPlayer == .white ? .system(size: 40, weight: .bold) : .system(size: 32))
                    .opacity(viewModel.currentPlayer == .white ? 1.0 : 0.3)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// セル（1マス）のView
struct CellView: View {
    var stone: Stone  // 盤面セルにある石の状態
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.green)
                .frame(width: 40, height: 40)
                .border(Color.black)
            if stone != .empty {
                Circle()
                    .fill(stone == .black ? Color.black : Color.white)
                    .frame(width: 30, height: 30)
            }
        }
    }
}

#Preview {
    OthelloBoardView(viewModel: OthelloViewModel())
}
