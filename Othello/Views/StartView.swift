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

    var body: some View {
        ZStack {
            // 背景
            Color.green
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    // 背景のアニメーション
                    MovingCircles()
                )

            VStack {
                Spacer()

                // タイトル
                Text("リバーシ")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 1), value: isAnimating)
                
                Spacer()
                
                // ゲーム開始ボタン
                Button(action: {
                    // ゲーム開始処理（画面遷移など)
                    isPresented = true // 画面遷移フラグを立てる

                }) {
                    Text("ゲーム開始")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 200)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 50)
                .animation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0), value: isAnimating)
                .padding(.bottom, 50)
                .fullScreenCover(isPresented: $isPresented) {
                    OthelloBoardView(viewModel: viewModel)
                }
                        
                Spacer()
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// 背景の動く光のエフェクト
struct MovingCircles: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: animate ? 100 : -100, y: animate ? -200 : 200)
                .blur(radius: 50)
            
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 400, height: 400)
                .offset(x: animate ? -150 : 150, y: animate ? 150 : -150)
                .blur(radius: 60)
        }
        .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)
        .onAppear {
            animate.toggle()
        }
    }
}


#Preview{
    StartView()
}
