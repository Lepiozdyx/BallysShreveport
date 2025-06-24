import SwiftUI

struct GameUIBottomPanel: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.getRoundDisplayText())")
                        .fontBangers(12)
                    Text("Regions: \(viewModel.humanCountry?.aliveRegionsCount ?? 0)")
                        .fontBangers(12)
                    Text("Income: \(viewModel.humanCountry?.totalIncome ?? 0)")
                        .fontBangers(12, color: .yellow)
                }
                
                Spacer()

                Button {
                    viewModel.endCurrentPhase()
                } label: {
                    ActionView(
                        width: 180,
                        height: 60,
                        text: "End Phase",
                        textSize: 24
                    )
                }
                .disabled(!viewModel.canEndPhase || viewModel.isProcessingTurn || viewModel.animationInProgress)
                .opacity(buttonOpacity)
            }
        }
        .padding(8)
    }
    
    private var buttonOpacity: Double {
        if viewModel.canEndPhase && !viewModel.isProcessingTurn && !viewModel.animationInProgress {
            return 1.0
        } else {
            return 0.6
        }
    }
}

#Preview {
    GameUIBottomPanel(viewModel: GameViewModel(gameManager: GameManager()))
}
