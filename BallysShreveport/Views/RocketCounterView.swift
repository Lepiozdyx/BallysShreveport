import SwiftUI

struct RocketCounterView: View {
    let rocketCount: Int
    
    var body: some View {
        Image(.button2)
            .resizable()
            .scaledToFit()
            .frame(width: 50)
            .overlay {
                VStack(spacing: -10) {
                    Image(.rocket)
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                    
                    Text("\(rocketCount)")
                        .fontBangers(18)
                }
            }
    }
}

#Preview {
    RocketCounterView(rocketCount: 2)
}
