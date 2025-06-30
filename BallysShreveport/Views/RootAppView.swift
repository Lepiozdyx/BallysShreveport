import SwiftUI

struct RootAppView: View {
    
    @StateObject private var state = AppStateViewModel()
    private var orientation = ScreenManager.shared
        
    var body: some View {
        Group {
            switch state.appState {
            case .fetch:
                LoadingView()
                
            case .supp:
                if let url = state.webManager.targetURL {
                    WebViewManager(url: url, webManager: state.webManager)
                        .onAppear {
                            orientation.unlock()
                        }
                    
                } else {
                    WebViewManager(url: NetworkManager.initialURL, webManager: state.webManager)
                        .onAppear {
                            orientation.unlock()
                        }
                }
                
            case .final:
                ContentView()
                    .preferredColorScheme(.light)
            }
        }
        .onAppear {
            state.stateCheck()
        }
    }
}

#Preview {
    RootAppView()
}
