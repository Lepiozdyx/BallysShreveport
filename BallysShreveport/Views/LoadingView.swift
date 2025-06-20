//
//  LoadingView.swift
//  BallysShreveport
//
//  Created by Alex on 20.06.2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            
            Text("Play your favorite game")
                .fontBangers(40, color: .red)
            
            ProgressView()
        }
        .padding()
    }
}

#Preview {
    LoadingView()
}
