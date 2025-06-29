import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        Group {
            if let gameManager = appViewModel.gameManager {
                ZStack {
                    BackgroundView()
                    
                    GameUIOverlay(viewModel: gameViewModel)
                    
                    GameFieldView(viewModel: gameViewModel)
                    
                    GameUIBottomPanel(viewModel: gameViewModel)
                    
                    if gameViewModel.showingRegionMenu {
                        RegionPurchaseMenu(viewModel: gameViewModel)
                    }
                    
                    if gameViewModel.showPauseMenu {
                        PauseMenuView(viewModel: gameViewModel)
                    }
                    
                    if gameViewModel.showResultScreen {
                        GameResultView(viewModel: gameViewModel)
                    }
                }
                .onAppear {
                    gameViewModel.setupWith(appViewModel: appViewModel, gameManager: gameManager)
                    gameViewModel.startNewGame()
                }
                .onChange(of: gameManagerId) { _ in
                    if let gameManager = appViewModel.gameManager {
                        gameViewModel.setupWith(appViewModel: appViewModel, gameManager: gameManager)
                        gameViewModel.startNewGame()
                    }
                }
            } else {
                // Loading state while GameManager is being created
                ZStack {
                    BackgroundView()
                    
                    VStack {
                        Text("Loading Game...")
                            .fontBangers(24)
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    }
                }
            }
        }
    }
    
    private var gameManagerId: ObjectIdentifier? {
        appViewModel.gameManager.map { ObjectIdentifier($0) }
    }
}

#Preview {
    let appViewModel = AppViewModel()
    appViewModel.gameManager = GameManager(opponentCount: 3)
    
    return GameView()
        .environmentObject(appViewModel)
}
