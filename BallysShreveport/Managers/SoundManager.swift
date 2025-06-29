import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    var audioPlayer: AVAudioPlayer?

    func playBackgroundMusic() {
        // Изменено: используем константы из GameConfiguration
        guard let url = Bundle.main.url(
            forResource: GameConfiguration.Audio.backgroundMusic,
            withExtension: GameConfiguration.Audio.backgroundMusicExtension
        ) else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Could not play background music: \(error)")
        }
    }

    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
