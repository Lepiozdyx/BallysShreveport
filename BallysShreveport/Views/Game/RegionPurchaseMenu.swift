import SwiftUI

struct RegionPurchaseMenu: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.closeRegionMenu()
                }
            
            VStack(spacing: 16) {
                Button {
                    viewModel.buyRocket()
                } label: {
                    ActionView(
                        width: 180,
                        height: 50,
                        text: viewModel.getRocketButtonText(),
                        textSize: 18
                    )
                }
                .disabled(!viewModel.canBuyRocket())
                .opacity(viewModel.canBuyRocket() ? 1.0 : 0.6)
                
                Button {
                    viewModel.buyAirDefense()
                } label: {
                    ActionView(
                        width: 180,
                        height: 50,
                        text: viewModel.getAirDefenseButtonText(),
                        textSize: 18
                    )
                }
                .disabled(!viewModel.canBuyAirDefense(for: viewModel.selectedRegionIndex ?? 0))
                .opacity(viewModel.canBuyAirDefense(for: viewModel.selectedRegionIndex ?? 0) ? 1.0 : 0.6)
            }
            .padding(.vertical, 60)
            .padding(.horizontal)
            .background(
                Image(.frame1)
                    .resizable()
                    .overlay(alignment: .topTrailing) {
                        Button {
                            viewModel.closeRegionMenu()
                        } label: {
                            Image(.button2)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .overlay {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.white)
                                }
                        }
                        .offset(x: 15, y: -15)
                    }
            )
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.showingRegionMenu)
        }
    }
}

#Preview {
    let gameViewModel = GameViewModel(gameManager: GameManager())
    gameViewModel.showingRegionMenu = true
    
    return RegionPurchaseMenu(viewModel: gameViewModel)
}
