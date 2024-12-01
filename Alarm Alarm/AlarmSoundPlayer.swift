//
//  SoundManager.swift
//  Alarm Alarm
//
//  Created by Lachlan Philipson on 14/12/2024.
//

import MediaPlayer

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    func playSound(soundName: String) {
        stopSoundWithFadeOut()

        guard
            let url = Bundle.main.url(
                forResource: soundName, withExtension: "wav")
        else {
            print("Sound file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Could not play sound: \(error.localizedDescription)")
        }
    }

    func stopSoundWithFadeOut(duration: TimeInterval = 0.25) {
        guard let player = audioPlayer, player.isPlaying else { return }

        player.setVolume(0, fadeDuration: duration)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            player.stop()
        }
    }

    func stopSound() {
        audioPlayer?.stop()
    }
}
