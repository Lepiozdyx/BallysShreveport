import SwiftUI

struct AIModeSetupView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
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
                    text: "Game settings",
                    textSize: 24
                )
                
                Spacer()
                
                VStack {
                    Text("Difficulty")
                        .fontBangers(22)
                    
                    SelectorTabView(selectedTab: $appViewModel.difficulty)
                }

                VStack {
                    Text("Number of opponents")
                        .fontBangers(22)
                    
                    HStack(spacing: 30) {
                        Button {
                            
                        } label: {
                            ActionView(
                                imageResource: .button2,
                                width: 80,
                                height: 80,
                                text: "1",
                                textSize: 24
                            )
                        }
                        
                        Button {
                            
                        } label: {
                            ActionView(
                                imageResource: .button2,
                                width: 80,
                                height: 80,
                                text: "2",
                                textSize: 24
                            )
                        }
                        
                        Button {
                            
                        } label: {
                            ActionView(
                                imageResource: .button2,
                                width: 80,
                                height: 80,
                                text: "3",
                                textSize: 24
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    AIModeSetupView()
        .environmentObject(AppViewModel())
}

// MARK: - Subviews
struct SelectorTabView: View {
    @Binding var selectedTab: AppViewModel.Difficulty
    let animation: Animation = .spring(response: 0.2, dampingFraction: 0.5)
    
    var body: some View {
        HStack(spacing: 20) {
            SelectorTabButton(
                title: "novice",
                isSelected: selectedTab == .novice,
                action: {
                    withAnimation(animation) {
                        selectedTab = .novice
                    }
                }
            )
            
            SelectorTabButton(
                title: "strategist",
                isSelected: selectedTab == .strategist,
                action: {
                    withAnimation(animation) {
                        selectedTab = .strategist
                    }
                }
            )
            
            SelectorTabButton(
                title: "agressor",
                isSelected: selectedTab == .agressor,
                action: {
                    withAnimation(animation) {
                        selectedTab = .agressor
                    }
                }
            )
        }
    }
}

struct SelectorTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ActionView(
                imageResource: .button1,
                width: 150,
                height: 50,
                text: title,
                textSize: 16
            )
            .scaleEffect(isSelected ? 1.0 : 0.7)
        }
    }
}
