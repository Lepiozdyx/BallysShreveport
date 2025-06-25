import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var appViewModel: AppViewModel
    
    init() {
        self._gameViewModel = StateObject(wrappedValue: GameViewModel(opponentCount: 3))
    }
    
    var body: some View {
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
            gameViewModel.setupWith(appViewModel: appViewModel)
            gameViewModel.startNewGame()
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
