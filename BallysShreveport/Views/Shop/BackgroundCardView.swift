import SwiftUI

struct BackgroundCardView: View {
    let backgroundItem: BackgroundItem
    let isSelected: Bool
    let canAfford: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text("#\(backgroundItem.displayIndex)")
                .fontBangers(28)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .frame(width: 120, height: 80)
                .overlay(
                    Image(backgroundItem.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 80)
                        .clipped()
                        .cornerRadius(8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 2)
                )
            
            // Action button
            Button {
                onTap()
            } label: {
                ActionView(
                    imageResource: .button1,
                    width: 120,
                    height: 50,
                    text: buttonState.text,
                    textSize: 16
                )
            }
            .disabled(!buttonState.isEnabled || !isActionEnabled)
            .opacity(buttonOpacity)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var buttonState: BackgroundButtonState {
        if isSelected {
            return .selected
        } else if backgroundItem.isOwned {
            return .select
        } else {
            return .buy(price: backgroundItem.price)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .yellow
        } else if backgroundItem.isOwned {
            return .green
        } else {
            return .gray
        }
    }
    
    private var isActionEnabled: Bool {
        switch buttonState {
        case .selected:
            return false
        case .select:
            return true
        case .buy:
            return canAfford
        }
    }
    
    private var buttonOpacity: Double {
        isActionEnabled ? 1.0 : 0.6
    }
}

#Preview {
    HStack {
        BackgroundCardView(
            backgroundItem: BackgroundItem(type: .bg),
            isSelected: true,
            canAfford: true,
            onTap: {}
        )
        
        BackgroundCardView(
            backgroundItem: BackgroundItem(type: .bg2),
            isSelected: false,
            canAfford: true,
            onTap: {}
        )
    }
}
