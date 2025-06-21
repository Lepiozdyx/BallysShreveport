import SwiftUI

class AppViewModel: ObservableObject {
    @Published var currentScreen: Navigation = .menu
    @Published var coins: Int = 0
    
    func navigateTo(_ screen: Navigation) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }
}
