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
        
//        viewModel.route.openPremium
//            .subscribe(onNext: { [weak self] in
//                self?.openPremium()
//            })
//            .disposed(by: disposeBag)
    }
    
    private func openVideoPlayer(with video: VideoEntity, on navController: UINavigationController) {
        let player = PlayerController(videoUrl: video.videoUrl)
        let viewModel = VideoPlayerViewModel(video: video, playerController: player)
        let viewController: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .fullScreen
        
        navigationController.present(viewController, animated: true, completion: nil)
        
        viewModel.route.openVideoSettings
            .observe(on: MainScheduler())
            .subscribe(onNext: { [weak self, weak viewController] videoSettingsSubject in
                guard let self = self, let vc = viewController else { return }
                self.openVideoSettings(with: videoSettingsSubject, on: vc)
            })
            .disposed(by: disposeBag)
        
        viewModel.route.close
            .observe(on: MainScheduler())
            .subscribe(onCompleted: { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func openUploadTutorial() {
        let viewModel = UploadTutorialViewModel()
        let viewController: UploadTutorialViewController = UploadTutorialViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        navigationController.present(navController, animated: true, completion: nil)
    }
    
//    private func openPremium() {
//        let viewModel = PurchasesViewModel()
//        let viewController: PurchasesViewController = PurchasesViewController.createFromMainStoryboard()
//        viewController.viewModel = viewModel
//
//        let navController = UINavigationController(rootViewController: viewController)
//        navController.modalPresentationStyle = .formSheet
//        navigationController.present(navController, animated: true, completion: nil)
//
//        viewModel.route.close
//            .drive(onNext: { [weak viewController] in
//                viewController?.dismiss(animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)
//    }
    
    private func openVideoSettings(with settingsSubject: BehaviorSubject<VideoSettings>, on vc: UIViewController) {
        let viewModel = VideoSettingsViewModel(settingsSubject: settingsSubject)
        
        let viewController: VideoSettingsViewController = VideoSettingsViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        
        let navController = UINavigationController(rootViewController: viewController)
        vc.present(navController, animated: true, completion: nil)
    }
}
