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
                guard let self = self else { return }
                self.openUploadTutorial()
            })
            .disposed(by: disposeBag)
    }
    
    private func openVideoPlayer(with video: VideoEntity, on navController: UINavigationController) {
        let source = video.subtitleUrl(for: 1)
        let target = video.subtitleUrl(for: 2)
        
        let viewModel = VideoPlayerViewModel(video: video, sourceSubUrl: source, targetSubUrl: target)
        let viewController: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .fullScreen
        
        navigationController.present(viewController, animated: true, completion: nil)
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
}
