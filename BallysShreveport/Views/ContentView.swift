import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .modeSelection:
                ModeSelectionView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .aiModeSetup:
                AIModeSetupView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .campaignLevelSelection:
                LevelSelectionView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .achievements:
                AchievementsView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appViewModel.currentScreen)
        .onAppear {
            ScreenManager.shared.lock()
            
            if appViewModel.musicEnabled {
                SoundManager.shared.playBackgroundMusic()
            }
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                ScreenManager.shared.lock()
                
                if appViewModel.musicEnabled {
                    SoundManager.shared.playBackgroundMusic()
                } else {
                    SoundManager.shared.stopBackgroundMusic()
                }
            case .background:
                SoundManager.shared.stopBackgroundMusic()
            case .inactive:
                SoundManager.shared.stopBackgroundMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
