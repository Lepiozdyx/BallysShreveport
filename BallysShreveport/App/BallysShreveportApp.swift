import SwiftUI

@main
struct BallysShreveportApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ScreenLockManager.orientationMask = .landscape
        ScreenLockManager.isAutoRotationEnabled = false
        
        if #available(iOS 14.0, *) {} else {
            let contentView = CustomHostingController(rootView: ContentView())
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = contentView
            window?.makeKeyAndVisible()
        }
        
        return true
    }
}
