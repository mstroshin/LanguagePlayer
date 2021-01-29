import Foundation
import UIKit

struct InterfaceOrientation {

    static func lock(orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
}
