import UIKit
import RxSwift

class TabBarCoordinator: BaseCoordinator<Void> {
    private let tabBar: UITabBarController
    
    init(tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
    
    override func start() -> Observable<Void> {
        let videoListVC = makeVideoListViewController()
        let videoListCoordinator = VideoCoordinator(videoListViewController: videoListVC)
        
        let cardsVC = makeCardsViewController()
        let cardsCoordinator = CardsCoordinator(cardsViewController: cardsVC)
        
        let settingsVC = makeSettingsViewController()
        let settingsCoordinator = SettingsCoordinator(settingsViewController: settingsVC)
        
        tabBar.viewControllers = [
            videoListVC,
            cardsVC,
            settingsVC,
        ]
        
        return .merge([
            videoListCoordinator.start(),
            cardsCoordinator.start(),
            settingsCoordinator.start(),
        ])
    }
    
    private func makeVideoListViewController() -> UIViewController {
        let viewModel = VideosListViewModel()
        
        let videoListViewController: VideosListViewController = VideosListViewController.createFromMainStoryboard()
        videoListViewController.viewModel = viewModel
        videoListViewController.tabBarItem = .init(title: "Video Library", image: UIImage(systemName: "list.and.film"), tag: 0)
        let navigationController = UINavigationController(rootViewController: videoListViewController)
        
        return navigationController
    }
    
    private func makeCardsViewController() -> UIViewController {
        let viewModel = CardsViewModel()
        
        let viewController: CardsViewController = CardsViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        viewController.tabBarItem = .init(title: "Cards", image: UIImage(systemName: "list.and.film"), tag: 1)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
    
    private func makeSettingsViewController() -> UIViewController {
        let viewModel = SettingsViewModel()
        
        let viewController: SettingsViewController = SettingsViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        viewController.tabBarItem = .init(title: "Settings", image: UIImage(systemName: "list.and.film"), tag: 2)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
    
}
