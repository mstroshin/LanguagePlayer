import UIKit

class DictionaryRouter: Router {
    
    override func navigate(to screen: Screen, type: TransitionType) {
        switch (screen, type) {
        case (.player, .present(let style)):
            let vc: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
            vc.modalPresentationStyle = style
            self.viewController?.present(vc, animated: true, completion: nil)
        default:
            break
        }
    }
    
}
