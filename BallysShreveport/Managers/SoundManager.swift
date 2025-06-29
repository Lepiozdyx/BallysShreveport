import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    var audioPlayer: AVAudioPlayer?
    
    private init() {}

    func playBackgroundMusic() {
        guard let url = Bundle.main.url(
            forResource: "music",
            withExtension: "mp3"
        ) else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("\(error)")
        }
    }

    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
