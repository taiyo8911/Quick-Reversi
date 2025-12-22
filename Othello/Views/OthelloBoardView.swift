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
        VStack {
            // 現在のプレイヤーまたはゲーム結果を表示
            Text(viewModel.isGameOver ? viewModel.gameOverText : "\(viewModel.currentPlayer == .black ? "黒" : "白")のターン")
                .font(.title)
                .padding()
            
            // 盤面の表示
            ForEach(0..<size, id: \.self) { row in
                HStack {
                    ForEach(0..<size, id: \.self) { col in
                        CellView(stone: viewModel.board[row][col])
                            .onTapGesture {
                                viewModel.placeStone(row: row, col: col)
                            }
                    }
                }
            }
            
            Spacer()
                .frame(height: 20) // ボタン表示用に一定のスペースを確保
            
            // もう一度あそぶボタン
            if viewModel.isGameOver {
                Button("もう一度あそぶ") {
                    viewModel.resetGame()
                }
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Spacer()
                    .frame(height: 50) // ボタンがないときもスペースを確保
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
