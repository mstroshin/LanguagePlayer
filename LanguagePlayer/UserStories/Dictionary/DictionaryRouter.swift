import UIKit

class DictionaryRouter: Router {
    weak var viewController: UIViewController?
    
    init(_ vc: UIViewController) {
        self.viewController = vc
    }
    
    func navigate(to screen: Screen, type: TransitionType) {
        switch (screen, type) {
        case (.player, .present(let style)):
            let vc: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
            vc.modalPresentationStyle = style
            self.viewController?.present(vc, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func newState(state: NavigationState) {
        if let newScreen = state.newScreen, let type = state.transitionType {
            self.navigate(to: newScreen, type: type)
        }
    }
    
}
