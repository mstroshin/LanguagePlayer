import UIKit
import RxSwift

class VideoCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = VideosListViewModel()
        
        let videoListViewController: VideosListViewController = VideosListViewController.createFromMainStoryboard()
        videoListViewController.viewModel = viewModel
        
        navigationController.pushViewController(videoListViewController, animated: false)
        
        return .never()
    }
}
