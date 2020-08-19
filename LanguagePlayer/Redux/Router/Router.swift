import UIKit
import ReSwift

class Router {
    private(set) weak var viewController: UIViewController?
    let screen: Screen
    
    init(_ vc: UIViewController, screen: Screen) {
        self.viewController = vc
        self.screen = screen
    }
    
    func navigate(to screen: Screen, type: TransitionType) {}
    
    func subscribeToStore() {
        store.subscribe(self) { $0.select { $0.navigation }}
    }
    
    func unsubscribeFromStore() {
        store.unsubscribe(self)
    }
    
}

extension Router: StoreSubscriber {
    typealias StoreSubscriberStateType = NavigationState

    func newState(state: NavigationState) {
        if let newScreen = state.newScreen, let type = state.transitionType {
            self.navigate(to: newScreen, type: type)
        }
    }
}
