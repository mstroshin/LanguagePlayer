import UIKit
import RxSwift

class CardsCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = CardsViewModel()
        viewModel.route.openVideo
            .subscribe(onNext: { [weak self] (video, time) in
                self?.open(video: video, from: time)
            })
            .disposed(by: disposeBag)
                
        let viewController: CardsViewController = CardsViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        
        navigationController.pushViewController(viewController, animated: false)
        
        return .never()
    }
    
    private func open(video: VideoEntity, from time: Milliseconds) {
        let player = PlayerController(videoUrl: URL(fileURLWithPath: video.filePath))
        let viewModel = VideoPlayerViewModel(video: video, playerController: player, startingTime: time)
        let viewController: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .fullScreen
        
        navigationController.present(viewController, animated: true, completion: nil)
        
        viewModel.route.close
            .observe(on: MainScheduler())
            .subscribe(onCompleted: {
                viewController.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
