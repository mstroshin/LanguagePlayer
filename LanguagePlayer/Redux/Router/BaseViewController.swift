import UIKit

class BaseViewController: UIViewController {
    var router: Router!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.router.subscribeToStore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.router.unsubscribeFromStore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.dispatch(NavigationActions.NavigationCompleted(currentScreen: self.router.screen))
    }
}
