import UIKit
import RxSwift

class SettingsCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = SettingsViewModel()
                
        let viewController: SettingsViewController = SettingsViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        
        navigationController.pushViewController(viewController, animated: false)
        
        return .never()
    }
}
