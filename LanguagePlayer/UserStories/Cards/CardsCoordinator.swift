import UIKit
import RxSwift

class CardsCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = CardsViewModel()
                
        let viewController: CardsViewController = CardsViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        
        navigationController.pushViewController(viewController, animated: false)
        
        return .never()
    }
}
