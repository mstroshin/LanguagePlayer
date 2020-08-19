import Foundation
import ReSwift

struct NavigationActions {
    
    struct Navigate: Action {
        let screen: Screen
        let transitionType: TransitionType
        let data: [AnyHashable: Any]?
    }
    
    struct NavigationCompleted: Action {
        let currentScreen: Screen
    }
    
}
