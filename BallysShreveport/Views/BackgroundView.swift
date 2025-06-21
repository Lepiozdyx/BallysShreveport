//
//  BackgroundView.swift
//  BallysShreveport
//
//  Created by Alex on 20.06.2025.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        Image(.bg)
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
