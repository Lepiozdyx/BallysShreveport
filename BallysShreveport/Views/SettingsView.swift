import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack {
                HStack(alignment: .top) {
                    Button {
                        dismiss()
                    } label: {
                        Image(GameConfiguration.Images.homeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: GameConfiguration.UI.smallIconHeight)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            
            ZStack {
                Image(GameConfiguration.Images.settingsFrame)
                    .resizable()
                    .scaledToFit()
                
                VStack(spacing: 20) {
                    Image(GameConfiguration.Images.settingsText)
                        .resizable()
                        .scaledToFit()
                        .frame(height: GameConfiguration.UI.settingsText)
                    
                    HStack(spacing: 80) {
                        Button {
                            appViewModel.setMusicEnabled(false)
                        } label: {
                            VStack {
                                Image(systemName: "speaker.slash.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.sand)
                                    .frame(height: GameConfiguration.UI.settingsButtonHeight)
                                
                                Text("OFF")
                                    .font(.system(size: GameConfiguration.UI.smallFontSize, weight: .bold))
                                    .foregroundStyle(.sand)
                            }
                            .shadow(color: .black, radius: 3, x: 1, y: 1)
                        }
                        
                        Button {
                            appViewModel.setMusicEnabled(true)
                        } label: {
                            VStack {
                                Image(systemName: "speaker.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.sand)
                                    .frame(height: GameConfiguration.UI.settingsButtonHeight)
                                
                                Text("ON")
                                    .font(.system(size: GameConfiguration.UI.smallFontSize, weight: .bold))
                                    .foregroundStyle(.sand)
                            }
                            .shadow(color: .black, radius: 3, x: 1, y: 1)
                        }
                    }
                }
            }
            .frame(
                width: GameConfiguration.UI.frameWidth,
                height: GameConfiguration.UI.frameHeight
            )
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
