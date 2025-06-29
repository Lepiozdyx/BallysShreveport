import SwiftUI

class ScreenLockManager {
    public static var orientationMask: UIInterfaceOrientationMask = .landscapeLeft
    public static var isAutoRotationEnabled: Bool = false
}

class ScreenManager {
    static let shared = ScreenManager()
    
    private init() {}
    
    func unlock() {
        ScreenLockManager.orientationMask = .all
        ScreenLockManager.isAutoRotationEnabled = true
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func lock() {
        ScreenLockManager.orientationMask = .landscape
        ScreenLockManager.isAutoRotationEnabled = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if windowScene.interfaceOrientation.isPortrait {
                ScreenLockManager.isAutoRotationEnabled = true
                UIViewController.attemptRotationToDeviceOrientation()
                
                if #available(iOS 16.0, *) {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                } else {
                    UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
                
                ScreenLockManager.isAutoRotationEnabled = false
            }
        }
    }
}

// MARK: - CustomHostingController
class CustomHostingController<Content: View>: UIHostingController<Content> {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return ScreenLockManager.orientationMask
    }

    override var shouldAutorotate: Bool {
        return ScreenLockManager.isAutoRotationEnabled
    }
}
