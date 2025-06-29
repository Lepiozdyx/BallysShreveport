import SwiftUI

struct GameUIOverlay: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Button {
                    viewModel.pauseGame()
                } label: {
                    ActionView(
                        imageResource: .button2,
                        width: 50,
                        height: 50,
                        text: "| |",
                        textSize: 18
                    )
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 2) {
                    Text(viewModel.currentPhaseDisplayName)
                        .fontBangers(14, color: .yellow)
                    
                    Text(viewModel.getCurrentPhaseInstructions())
                        .fontBangers(14, color: .white)
                        .lineLimit(1)
                }
                
                Spacer()
                
                CoinsView(amount: viewModel.humanPlayer?.coins ?? 0)
            }
            
            Spacer()
            
            HStack {
                RocketCounterView(rocketCount: viewModel.humanPlayer?.availableRockets ?? 0)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    GameUIOverlay(viewModel: GameViewModel())
}
