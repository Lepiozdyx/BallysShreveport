import SwiftUI

struct AchievementsView: View {
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
                            text: "←",
                            textSize: 24
                        )
                    }
                    
                    Spacer()
                    
                    CoinsView(amount: appViewModel.coins)
                }
                
                Spacer()
            }
            .padding()
            
            VStack {
                ActionView(
                    imageResource: .underlay2,
                    width: 300,
                    height: 80,
                    text: "ACHIEVEMENTS",
                    textSize: 24
                )
                
                Spacer()
                
                VStack {
                    HStack {
                        ForEach(Array(appViewModel.achievementManager.achievements.prefix(3).enumerated()), id: \.element.id) { index, achievement in
                            AchievementCardView(achievement: achievement)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        ForEach(Array(appViewModel.achievementManager.achievements.suffix(2).enumerated()), id: \.element.id) { index, achievement in
                            AchievementCardView(achievement: achievement)
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: 650)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AppViewModel())
}
