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
            
            HStack(spacing: 16) {
                VStack {
                    Image(.button2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .overlay {
                            VStack(spacing: 0) {
                                Text("air defense")
                                    .fontBangers(14)
                                
                                Image(.airdefense)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(8)
                            }
                            .padding()
                        }
                    
                    Button {
                        viewModel.buyAirDefense()
                    } label: {
                        ActionView(
                            width: 180,
                            height: 60,
                            text: viewModel.getAirDefenseButtonText(),
                            textSize: 18
                        )
                    }
                    .disabled(!viewModel.canBuyAirDefense(for: viewModel.selectedRegionIndex ?? 0))
                    .opacity(viewModel.canBuyAirDefense(for: viewModel.selectedRegionIndex ?? 0) ? 1.0 : 0.6)
                }
                
                VStack {
                    Image(.button2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .overlay {
                            VStack(spacing: 0) {
                                Text("nuclear \nmissile")
                                    .fontBangers(14)
                                
                                Image(.rocket)
                                    .resizable()
                                    .scaledToFit()
                            }
                            .padding()
                        }
                    
                    Button {
                        viewModel.buyRocket()
                    } label: {
                        ActionView(
                            width: 180,
                            height: 60,
                            text: viewModel.getRocketButtonText(),
                            textSize: 18
                        )
                    }
                    .disabled(!viewModel.canBuyRocket())
                    .opacity(viewModel.canBuyRocket() ? 1.0 : 0.6)
                }
            }
            .padding(.vertical, 60)
            .padding(.horizontal)
            .background(
                Image(.frame1)
                    .resizable()
                    .opacity(0.5)
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
    RegionPurchaseMenu(viewModel: GameViewModel())
}
