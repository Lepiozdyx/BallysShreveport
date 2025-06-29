import SwiftUI

struct CoinsView: View {
    
    let amount: Int
    
    var body: some View {
        Image(.underlay1)
            .resizable()
            .frame(width: 140, height: 40)
            .overlay(alignment: .leading) {
                ZStack {
                    Image(.button2)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                    
                    Image(.coin)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                }
                .offset(x: -5)
            }
            .overlay {
                Text("\(amount)")
                    .fontBangers(18)
                    .offset(x: 10)
            }
    }
}

#Preview {
    CoinsView(amount: 9999)
}
