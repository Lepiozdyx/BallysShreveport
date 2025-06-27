import SwiftUI

extension Text {
    func fontBangers(_ size: CGFloat, color: Color = .white, textAlignment: TextAlignment = .center) -> some View {
        let baseFont = UIFont(name: "Bangers", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        
        let scaledFont = UIFontMetrics(forTextStyle: .headline).scaledFont(for: baseFont)

        return self
            .font(Font(scaledFont))
            .foregroundStyle(color)
            .shadow(color: .black, radius: 1)
            .multilineTextAlignment(textAlignment)
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
