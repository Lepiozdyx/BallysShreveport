import SwiftUI

struct GameResultView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(viewModel.getGameEndMessage())
                    .fontBangers(28, color: resultColor)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    Text("Game Statistics")
                        .fontBangers(20, color: .white)
                    
                    Text("Rounds Played: \(viewModel.gameResult?.roundsPlayed ?? 0)")
                        .fontBangers(18, color: .white)
                    
                    if let result = viewModel.gameResult {
                        Text("Your Regions: \(result.finalRegionCounts[0] ?? 0)")
                            .fontBangers(18, color: .white)
                    }
                    
                    if viewModel.gameResult?.state == .victory {
                        Text("Reward: +100 coins")
                            .fontBangers(20, color: .yellow)
                    }
                }
                
                VStack(spacing: 20) {
                    Button {
                        viewModel.startNewGame()
                    } label: {
                        ActionView(
                            width: 150,
                            height: 60,
                            text: "New Game",
                            textSize: 20
                        )
                    }
                    
                    Button {
                        viewModel.exitToMenu()
                    } label: {
                        ActionView(
                            imageResource: .button1,
                            width: 150,
                            height: 60,
                            text: "Main Menu",
                            textSize: 20
                        )
                    }
                }
            }
            .padding(40)
            .background(
                Image(.frame2)
                    .resizable()
            )
        }
    }
    
    private var resultColor: Color {
        guard let gameResult = viewModel.gameResult else { return .white }
        
        switch gameResult.state {
        case .victory:
            return .green
        case .defeat:
            return .red
        case .draw, .maxRoundsReached:
            return .yellow
        case .notStarted, .inProgress:
            return .white
        }
    }
}

#Preview {
    let gameViewModel = GameViewModel(gameManager: GameManager())
    gameViewModel.showResultScreen = true
    
    return GameResultView(viewModel: gameViewModel)
}
