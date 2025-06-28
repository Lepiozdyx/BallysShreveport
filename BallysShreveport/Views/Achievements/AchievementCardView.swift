import SwiftUI

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(.button2)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
            .overlay {
                Image(achievement.iconName)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .fontBangers(16)
                
                Text(achievement.description)
                    .fontBangers(12, textAlignment: .leading)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(.button2)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
            }
        }
        .padding()
        .background(
            Image(.underlay3)
                .resizable()
        )
        .frame(maxWidth: 250)
    }
}

#Preview {
    AchievementCardView(
        achievement: Achievement(type: .shopper)
    )
}
