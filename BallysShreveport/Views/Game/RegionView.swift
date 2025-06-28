import SwiftUI

struct RegionView: View {
    let regionDef: RegionDefinition
    let countryIndex: Int
    let regionIndex: Int
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Image(regionDef.shape.imageName)
                .resizable()
                .frame(width: regionDef.width, height: regionDef.height)
                .opacity(regionOpacity)
                .colorMultiply(regionColorMultiplier)
                .onTapGesture {
                    viewModel.handleRegionTap(
                        countryIndex: countryIndex,
                        regionIndex: regionIndex,
                        position: regionDef.position
                    )
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.isRegionTargeted(countryIndex: countryIndex, regionIndex: regionIndex))
                .animation(.easeInOut(duration: 1.5), value: viewModel.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex))
            
            // Only show air defense icon on human player's regions
            if viewModel.regionHasAirDefense(countryIndex: countryIndex, regionIndex: regionIndex) &&
               viewModel.isHumanRegion(countryIndex: countryIndex) {
                Image(.airdefense)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .opacity(regionOpacity)
                    .animation(.easeInOut(duration: 1.5), value: viewModel.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex))
            }
            
            if viewModel.isRegionExploding(countryIndex: countryIndex, regionIndex: regionIndex) {
                Image(.boom)
                    .resizable()
                    .scaledToFit()
                    .frame(height: regionDef.height * 0.8)
                    .opacity(explosionOpacity)
                    .scaleEffect(explosionScale)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.isRegionExploding(countryIndex: countryIndex, regionIndex: regionIndex))
            }
        }
    }
    
    private var regionOpacity: Double {
        viewModel.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex) ? 0.5 : 1.0
    }
    
    private var regionColorMultiplier: Color {
        if viewModel.isRegionDestroyed(countryIndex: countryIndex, regionIndex: regionIndex) {
            return .gray
        }
        
        // Targeting phase - highlight targeted enemy regions in red
        if viewModel.currentPhase == .targeting &&
           !viewModel.isHumanRegion(countryIndex: countryIndex) &&
           viewModel.isRegionTargeted(countryIndex: countryIndex, regionIndex: regionIndex) {
            return .red
        }
        
        // Economy phase - highlight selected human region in blue
        if viewModel.currentPhase == .economy &&
           viewModel.selectedRegionIndex == regionIndex &&
           viewModel.isHumanRegion(countryIndex: countryIndex) {
            return .blue.opacity(0.3)
        }
        
        return .white
    }
    
    private var explosionOpacity: Double {
        viewModel.isRegionExploding(countryIndex: countryIndex, regionIndex: regionIndex) ? 1.0 : 0.0
    }
    
    private var explosionScale: Double {
        viewModel.isRegionExploding(countryIndex: countryIndex, regionIndex: regionIndex) ? 1.0 : 0.5
    }
}

#Preview {
    let sampleRegion = RegionDefinition(
        shape: .usa1,
        position: CGPoint(x: 100, y: 100),
        width: 80,
        height: 80,
        country: .usa
    )
    
    let appViewModel = AppViewModel()
    let gameManager = GameManager(opponentCount: 3)
    let gameViewModel = GameViewModel()
    
    gameViewModel.setupWith(appViewModel: appViewModel, gameManager: gameManager)
    
    return RegionView(
        regionDef: sampleRegion,
        countryIndex: 0,
        regionIndex: 0,
        viewModel: gameViewModel
    )
}

