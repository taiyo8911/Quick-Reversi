//
//  SoundManager.swift
//  Othello
//
//  Created by Taiyo KOSHIBA on 2025/02/25.
//

import AudioToolbox

class SoundManager {
    static func playCorrectSound() {
        AudioServicesPlaySystemSound(1105) // 石を置ける場所をタップした時の音
    }
    static func playGameOverSound() {
        AudioServicesPlaySystemSound(1009) // ゲーム終了時の音
    }
}
