import UIKit
import ReSwift

protocol Router: StoreSubscriber where StoreSubscriberStateType == NavigationState {
    var viewController: UIViewController? { get set }
    
    func navigate(to screen: Screen, type: TransitionType)
}

extension Router {
    func subscribe() {
        store.subscribe(self) { $0.select { $0.navigation }}
    }
    
    func unsubscribe() {
        store.unsubscribe(self)
    }
}
