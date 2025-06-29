import SwiftUI

struct ActionView: View {
    var imageResource: ImageResource = .button1
    
    let width: CGFloat
    let height: CGFloat
    let text: String
    let textSize: CGFloat
    
    var body: some View {
        Image(imageResource)
            .resizable()
            .frame(maxWidth: width, maxHeight: height)
            .overlay {
                Text(text)
                    .fontBangers(textSize)
                    .padding(4)
            }
    }
}

#Preview {
    VStack {
        ActionView(width: 250, height: 100, text: "Shop", textSize: 32)
        ActionView(imageResource: .button2, width: 80, height: 80, text: "Buy", textSize: 22)
    }
}
