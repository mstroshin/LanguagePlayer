import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let tabBarController = UITabBarController()
        let tabBarCoordinator = TabBarCoordinator(tabBar: tabBarController)
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        return coordinate(to: tabBarCoordinator)
    }
    
}
