import Foundation
import UIKit

struct InterfaceOrientation {

    static func lock(orientation: UIInterfaceOrientationMask, rotation: UIDeviceOrientation) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
        
        UIDevice.current.setValue(rotation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
}
