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
        
        bind(viewModel)
        
        return .never()
    }
    
    private func bind(_ viewModel: VideosListViewModel) {
        viewModel.route.openVideo
            .subscribe(onNext: { [weak self] video in
                guard let self = self else { return }
                self.openVideoPlayer(with: video, on: self.navigationController)
            })
            .disposed(by: disposeBag)
        
        viewModel.route.openUploadTutorial
            .subscribe(onNext: { [weak self] video in
                self?.openUploadTutorial()
            })
            .disposed(by: disposeBag)
        
        viewModel.route.openPremium
            .subscribe(onNext: { [weak self] in
                self?.openPremium()
            })
            .disposed(by: disposeBag)
    }
    
    private func openVideoPlayer(with video: VideoEntity, on navController: UINavigationController) {
        let viewModel = VideoPlayerViewModel(video: video)
        let viewController: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .fullScreen
        
        navigationController.present(viewController, animated: true, completion: nil)
        
        viewModel.route.close
            .observeOn(MainScheduler())
            .subscribe(onCompleted: {
                viewController.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func openUploadTutorial() {
        let viewModel = UploadTutorialViewModel()
        let viewController: UploadTutorialViewController = UploadTutorialViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        
        navigationController.present(viewController, animated: true, completion: nil)
        
        viewModel.route.videoLoaded
            .observeOn(MainScheduler())
            .subscribe(onCompleted: {
                viewController.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func openPremium() {
        let viewModel = PurchasesViewModel()
        let viewController: PurchasesViewController = PurchasesViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        
        navigationController.present(viewController, animated: true, completion: nil)
    }
}
