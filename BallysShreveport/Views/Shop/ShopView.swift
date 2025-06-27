import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    
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
                    text: "STORE",
                    textSize: 24
                )
                
                Spacer()
                
                HStack(spacing: 20) {
                    ForEach(appViewModel.backgrounds) { backgroundItem in
                        BackgroundCardView(
                            backgroundItem: backgroundItem,
                            isSelected: appViewModel.currentBackground == backgroundItem.type,
                            canAfford: appViewModel.canSpendCoins(backgroundItem.price),
                            onTap: {
                                appViewModel.handleBackgroundAction(for: backgroundItem.type)
                            }
                        )
                    }
                }
                .frame(maxWidth: 600)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}
