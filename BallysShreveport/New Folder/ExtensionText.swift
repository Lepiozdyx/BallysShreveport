//
//  ExtensionText.swift
//  BallysShreveport
//
//  Created by Alex on 20.06.2025.
//

import SwiftUI

extension Text {
    func fontBangers(_ size: CGFloat, color: Color = .white) -> some View {
        let baseFont = UIFont(name: "Bangers", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
        
        let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)

        return self
            .font(Font(scaledFont))
            .foregroundStyle(color)
            .shadow(color: .black, radius: 1)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}

struct ExtensionText: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .fontBangers(32)
    }
}

#Preview {
    ExtensionText()
}
