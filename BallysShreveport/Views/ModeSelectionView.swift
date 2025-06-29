import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HStack(alignment: .top) {
                    Button {
                        appViewModel.navigateBackToMenu()
                    } label: {
                        ActionView(
                            imageResource: .button2,
                            width: 50,
                            height: 50,
                            text: "\u{2190}",
                            textSize: 24
                        )
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            
            VStack {
                ActionView(
                    imageResource: .underlay2,
                    width: 300,
                    height: 80,
                    text: "Mode selection",
                    textSize: 24
                )
                
                Spacer()
                
                Button {
                     appViewModel.navigateToCampaignLevelSelection()
                } label: {
                    ActionView(
                        imageResource: .button1,
                        width: 200,
                        height: 80,
                        text: "Campaign",
                        textSize: 24
                    )
                }

                HStack(spacing: 30) {
                    Button {
                        appViewModel.navigateToAIModeSetup()
                    } label: {
                        ActionView(
                            imageResource: .button1,
                            width: 200,
                            height: 80,
                            text: "vs AI",
                            textSize: 24
                        )
                    }
                    
                    Button {
                        // appViewModel.navigateTo..
                    } label: {
                        ActionView(
                            imageResource: .button1,
                            width: 200,
                            height: 80,
                            text: "Multiplayer",
                            textSize: 22
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ModeSelectionView()
        .environmentObject(AppViewModel())
}
