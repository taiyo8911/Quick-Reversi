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

    private let bgDark = Color(red: 0.05, green: 0.18, blue: 0.12)
    private let bgLight = Color(red: 0.09, green: 0.28, blue: 0.18)

    var body: some View {
        ZStack {
            // StartViewと統一した深いグリーンのグラデーション背景
            LinearGradient(
                colors: [bgDark, bgLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 柔らかなトップライト
            RadialGradient(
                colors: [Color.white.opacity(0.10), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 白プレイヤー側（180°回転して対面プレイヤーに正立表示）
                ScoreCard(
                    stoneColor: .white,
                    count: viewModel.model.stoneCounts().white,
                    isActive: viewModel.currentPlayer == .white
                )
                .rotationEffect(.degrees(180))
                .padding(.top, 12)

                Spacer(minLength: 8)

                // 盤面（カード化、画面幅に追従）
                BoardGridView(viewModel: viewModel, size: size)
                    .padding(.horizontal, 16)

                Spacer(minLength: 8)

                // 黒プレイヤー側（手前のプレイヤー）
                ScoreCard(
                    stoneColor: .black,
                    count: viewModel.model.stoneCounts().black,
                    isActive: viewModel.currentPlayer == .black
                )
                .padding(.bottom, 12)
            }

            // ゲーム終了オーバーレイ
            if viewModel.isGameOver {
                GameOverOverlay(
                    blackCount: viewModel.model.stoneCounts().black,
                    whiteCount: viewModel.model.stoneCounts().white,
                    onPlayAgain: { viewModel.resetGame() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeOut(duration: 0.35), value: viewModel.isGameOver)
    }
}

// ゲーム終了時のオーバーレイ（対面プレイ用に上下ミラー表示）
struct GameOverOverlay: View {
    let blackCount: Int
    let whiteCount: Int
    let onPlayAgain: () -> Void

    private var resultTitle: String {
        if blackCount > whiteCount { return "Black Wins" }
        if whiteCount > blackCount { return "White Wins" }
        return "Draw"
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // 白プレイヤー側
                ResultCard(title: resultTitle,
                           blackCount: blackCount,
                           whiteCount: whiteCount,
                           onPlayAgain: onPlayAgain)
                    .rotationEffect(.degrees(180))

                // 黒プレイヤー側
                ResultCard(title: resultTitle,
                           blackCount: blackCount,
                           whiteCount: whiteCount,
                           onPlayAgain: onPlayAgain)
            }
            .padding(.horizontal, 32)
        }
    }
}

// 結果カード（1プレイヤー分）
struct ResultCard: View {
    let title: String
    let blackCount: Int
    let whiteCount: Int
    let onPlayAgain: () -> Void

    private let boardGreen = Color(red: 0.07, green: 0.24, blue: 0.16)
    private let cardLight = Color(red: 0.11, green: 0.33, blue: 0.22)
    private let cardDark = Color(red: 0.06, green: 0.20, blue: 0.13)

    var body: some View {
        VStack(spacing: 14) {
            Text("GAME OVER")
                .font(.system(size: 10, weight: .medium))
                .tracking(5)
                .foregroundColor(.white.opacity(0.55))

            Text(title)
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundColor(.white)

            HStack(spacing: 20) {
                FinalScoreItem(color: .black, count: blackCount)
                Text("—")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.white.opacity(0.35))
                FinalScoreItem(color: .white, count: whiteCount)
            }

            Button(action: onPlayAgain) {
                HStack(spacing: 8) {
                    Text("Play Again")
                        .font(.system(size: 15, weight: .semibold))
                        .tracking(1)
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(boardGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 3)
                )
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(colors: [cardLight, cardDark],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 22, x: 0, y: 10)
    }
}

struct FinalScoreItem: View {
    let color: Color
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 34, height: 34)
                .overlay(
                    Circle().strokeBorder(Color.white.opacity(color == .black ? 0.12 : 0), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            Text("\(count)")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
        }
    }
}

// 盤面グリッド（カード状の1枚パネル）
struct BoardGridView: View {
    @ObservedObject var viewModel: OthelloViewModel
    let size: Int

    private let boardGreen = Color(red: 0.13, green: 0.42, blue: 0.27)
    private let boardGreenDark = Color(red: 0.08, green: 0.30, blue: 0.19)
    private let gridLine = Color.black.opacity(0.35)

    var body: some View {
        GeometryReader { geo in
            let cellSize = geo.size.width / CGFloat(size)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(colors: [boardGreen, boardGreenDark],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )

                VStack(spacing: 0) {
                    ForEach(0..<size, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<size, id: \.self) { col in
                                CellView(stone: viewModel.board[row][col],
                                         cellSize: cellSize,
                                         gridLine: gridLine)
                                    .onTapGesture {
                                        viewModel.placeStone(row: row, col: col)
                                    }
                            }
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.black.opacity(0.45), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 8)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// スコアカード（1プレイヤー分の石数と手番を表示）
struct ScoreCard: View {
    let stoneColor: Color
    let count: Int
    let isActive: Bool

    private let cardBackground = Color(red: 0.07, green: 0.24, blue: 0.16)

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(stoneColor)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(stoneColor == .black ? 0.12 : 0), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)

            Text("\(count)")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(cardBackground)
                .shadow(color: .black.opacity(isActive ? 0.4 : 0.2),
                        radius: isActive ? 10 : 4,
                        x: 0, y: isActive ? 4 : 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(isActive ? 0.7 : 0), lineWidth: 2)
        )
        .scaleEffect(isActive ? 1.06 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isActive)
    }
}

// セル（1マス）のView
struct CellView: View {
    var stone: Stone  // 盤面セルにある石の状態
    var cellSize: CGFloat = 40
    var gridLine: Color = Color.black.opacity(0.35)

    var body: some View {
        ZStack {
            // 透過セル本体（盤の緑が透けて見える）
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .overlay(
                    // 控えめなグリッド線（右辺・下辺のみ描いて重なりを防ぐ）
                    Path { path in
                        path.move(to: CGPoint(x: cellSize, y: 0))
                        path.addLine(to: CGPoint(x: cellSize, y: cellSize))
                        path.move(to: CGPoint(x: 0, y: cellSize))
                        path.addLine(to: CGPoint(x: cellSize, y: cellSize))
                    }
                    .stroke(gridLine, lineWidth: 0.5)
                )

            if stone != .empty {
                Circle()
                    .fill(stone == .black ? Color.black : Color.white)
                    .frame(width: cellSize * 0.78, height: cellSize * 0.78)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .contentShape(Rectangle())
    }
}

#Preview {
    OthelloBoardView(viewModel: OthelloViewModel())
}
#Preview("Game Over Overlay") {
    ZStack {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.18, blue: 0.12),
                     Color(red: 0.09, green: 0.28, blue: 0.18)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        GameOverOverlay(blackCount: 38, whiteCount: 26, onPlayAgain: {})
    }
}

