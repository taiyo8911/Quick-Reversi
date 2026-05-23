//
//  StartView.swift
//  Othello
//
//  Created by Taiyo KOSHIBA on 2025/02/12.
//

import SwiftUI

struct StartView: View {
    @State private var isAnimating = false
    @State private var isPresented: Bool = false // 画面遷移フラグ
    @ObservedObject var viewModel = OthelloViewModel()

    private let boardGreen = Color(red: 0.07, green: 0.24, blue: 0.16)
    private let boardGreenLight = Color(red: 0.10, green: 0.34, blue: 0.22)

    var body: some View {
        ZStack {
            // 背景: 深いグリーンのグラデーション
            LinearGradient(
                colors: [boardGreen, boardGreenLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 柔らかなハイライト
            RadialGradient(
                colors: [Color.white.opacity(0.12), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // オセロを象徴する黒白のディスク
                ZStack {
                    DiscView(color: .white)
                        .offset(x: -26)
                    DiscView(color: .black)
                        .offset(x: 26)
                }
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1 : 0.85)
                .animation(.easeOut(duration: 0.9), value: isAnimating)

                Spacer().frame(height: 44)

                // タイトル
                Text("Reversi")
                    .font(.system(size: 56, weight: .semibold, design: .serif))
                    .foregroundColor(.white)
                    .tracking(4)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 1).delay(0.2), value: isAnimating)

                Spacer()

                // ゲーム開始ボタン
                Button(action: {
                    isPresented = true
                }) {
                    HStack(spacing: 10) {
                        Text("Start Game")
                            .font(.system(size: 17, weight: .semibold))
                            .tracking(1)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(boardGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 6)
                    )
                }
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(.spring(response: 0.7, dampingFraction: 0.78).delay(0.5), value: isAnimating)
                .fullScreenCover(isPresented: $isPresented) {
                    OthelloBoardView(viewModel: viewModel)
                }

                Spacer().frame(height: 120)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// オセロの石モチーフ
private struct DiscView: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 72, height: 72)
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(color == .black ? 0.08 : 0), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 5)
    }
}


#Preview{
    StartView()
}
