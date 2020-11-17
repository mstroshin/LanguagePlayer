import UIKit
import RxSwift

class TabBarCoordinator: BaseCoordinator<Void> {
    private let tabBar: UITabBarController
    
    init(tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
    
    override func start() -> Observable<Void> {
        let videoListNavigationController = UINavigationController()
        videoListNavigationController.tabBarItem = .init(title: "Video Library", image: UIImage(systemName: "list.and.film"), tag: 0)
        
        let cardsNavigationController = UINavigationController()
        cardsNavigationController.tabBarItem = .init(title: "Cards", image: UIImage(systemName: "note.text"), tag: 1)
        
        let settingsNavigationController = UINavigationController()
        settingsNavigationController.tabBarItem = .init(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)
        
        tabBar.viewControllers = [
            videoListNavigationController,
            cardsNavigationController,
            settingsNavigationController,
        ]
        
        let videoListCoordinator = VideoCoordinator(navigationController: videoListNavigationController)
        coordinate(to: videoListCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        let cardsCoordinator = CardsCoordinator(navigationController: cardsNavigationController)
        coordinate(to: cardsCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNavigationController)
        coordinate(to: settingsCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        return .never()
    }
    
}
