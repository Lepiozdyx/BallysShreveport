import SwiftUI

struct BackgroundView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        Image(appViewModel.currentBackground.imageName)
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
        .environmentObject(AppViewModel())
}
