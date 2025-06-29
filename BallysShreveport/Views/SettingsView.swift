import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HStack(alignment: .top) {
                    Button {
                        appViewModel.navigateBackToMenu()
                    } label: {
                        ActionView(
                            imageResource: .button2,
                            width: 50,
                            height: 50,
                            text: "←",
                            textSize: 24
                        )
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            
            VStack {
                Text("Music")
                    .fontBangers(22)
                
                HStack(spacing: 24) {
                    Button {
                        appViewModel.setMusicEnabled(false)
                    } label: {
                        ActionView(
                            imageResource: .button2,
                            width: 60,
                            height: 60,
                            text: "OFF",
                            textSize: 20
                        )
                    }
                    
                    Button {
                        appViewModel.setMusicEnabled(true)
                    } label: {
                        ActionView(
                            imageResource: .button2,
                            width: 60,
                            height: 60,
                            text: "ON",
                            textSize: 20
                        )
                    }
                }
                
                Text("Language")
                    .fontBangers(22)
                
                Image(.button2)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .overlay {
                        Image(.flag)
                            .resizable()
                            .scaledToFit()
                            .padding(8)
                    }
            }
            .padding(40)
            .background(
                Image(.frame2)
                    .resizable()
            )
            .overlay(alignment: .top) {
                ActionView(
                    imageResource: .underlay2,
                    width: 200,
                    height: 50,
                    text: "Settings",
                    textSize: 18
                )
                .offset(y: -25)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
