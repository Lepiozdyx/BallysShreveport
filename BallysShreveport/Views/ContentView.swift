//
//  ContentView.swift
//  BallysShreveport
//
//  Created by Alex on 20.06.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .modeSelection:
                ModeSelectionView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .aiModeSetup:
                AIModeSetupView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .settings:
                // Temp
                MenuView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .shop:
                // Temp
                MenuView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .achievements:
                // Temp
                MenuView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appViewModel.currentScreen)
    }
}

#Preview {
    ContentView()
}
