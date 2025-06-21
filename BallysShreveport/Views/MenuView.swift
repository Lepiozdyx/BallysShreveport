//
//  MenuView.swift
//  BallysShreveport
//
//  Created by Alex on 20.06.2025.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                
                Spacer()
            }
            .padding()
            
            VStack {
                HStack(alignment: .top) {
                    Spacer()
                    
                    CoinsView(amount: appViewModel.coins)
                }
                
                Spacer()
            }
            .padding()
            
            VStack(spacing: 10) {
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        appViewModel.navigateTo(.game)
                    } label: {
                        ActionView(width: 260, height: 90, text: "play", textSize: 40)
                    }
                    
                    Button {
                        appViewModel.navigateTo(.shop)
                    } label: {
                        ActionView(width: 260, height: 90, text: "shop", textSize: 40)
                    }
                }
                
                HStack(spacing: 20) {
                    Button {
                        appViewModel.navigateTo(.achievements)
                    } label: {
                        ActionView(width: 260, height: 90, text: "achievements", textSize: 40)
                    }
                    
                    Button {
                        appViewModel.navigateTo(.settings)
                    } label: {
                        ActionView(width: 260, height: 90, text: "settings", textSize: 40)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}
