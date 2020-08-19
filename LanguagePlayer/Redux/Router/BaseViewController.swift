import Foundation
import UIKit
import ReSwift

//class BaseViewController: UIViewController {
//    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        self.configure()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        self.configure()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if let screen = self.screen, !screen.isTab, let router = self.getRouter() {
//            RouterRegistry.add(router, for: screen)
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if let screen = self.screen, !screen.isTab {
//            RouterRegistry.removeRouter(for: screen)
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if let screen = self.screen {
//            store.dispatch(NavigationActions.TransitionCompleted(currentScreen: screen))
//        }
//    }
//    
//    private func configure() {
//        if let screen = self.screen, let router = self.getRouter() {
//            RouterRegistry.add(router, for: screen)
//        }
//    }
//    
//    public var screen: Screen? {
//        Screen(rawValue: NSStringFromClass(type(of: self)))
//    }
//    
//    func getRouter() -> Router? {
//        nil
//    }
//}
