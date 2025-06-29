import SwiftUI

struct PauseMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Game Paused")
                    .fontBangers(40, color: .yellow)
                
                Button {
                    viewModel.resumeGame()
                } label: {
                    ActionView(
                        width: 200,
                        height: 60,
                        text: "Continue",
                        textSize: 24
                    )
                }
                
                Button {
                    viewModel.exitToMenu()
                } label: {
                    ActionView(
                        imageResource: .button1,
                        width: 200,
                        height: 60,
                        text: "Main Menu",
                        textSize: 24
                    )
                }
            }
            .padding(40)
            .background(
                Image(.frame2)
                    .resizable()
            )
        }
    }
}

#Preview {
    PauseMenuView(viewModel: GameViewModel())
}
