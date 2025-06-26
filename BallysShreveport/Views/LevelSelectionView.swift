import SwiftUI

struct LevelSelectionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 5)
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HStack(alignment: .top) {
                    Button {
                        appViewModel.navigateToModeSelection()
                    } label: {
                        ActionView(
                            imageResource: .button2,
                            width: 50,
                            height: 50,
                            text: "←",
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
                    text: "Level Selection",
                    textSize: 24
                )
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(appViewModel.campaignManager.levels) { level in
                        LevelButton(
                            level: level,
                            onTap: {
                                if level.isPlayable {
                                    appViewModel.navigateToCampaignGame(level: level.levelNumber)
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: 550)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct LevelButton: View {
    let level: CampaignLevel
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                Image(.button2)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .opacity(buttonOpacity)
                
                if level.status == .locked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                } else {
                    Text(level.displayText)
                        .fontBangers(28, color: textColor)
                }
            }
        }
        .disabled(!level.isPlayable)
    }
    
    private var buttonOpacity: Double {
        switch level.status {
        case .locked:
            return 0.5
        case .unlocked:
            return 1.0
        case .completed:
            return 0.8
        }
    }
    
    private var textColor: Color {
        switch level.status {
        case .locked:
            return .gray
        case .unlocked:
            return .white
        case .completed:
            return .yellow
        }
    }
}

#Preview {
    LevelSelectionView()
        .environmentObject(AppViewModel())
}
