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
        let player = PlayerController(videoUrl: video.videoUrl)
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
        
        viewModel.route.openVideoSettings
            .observe(on: MainScheduler())
            .subscribe(onNext: { [weak self, weak viewController] videoSettingsSubject in
                guard let self = self, let vc = viewController else { return }
                self.openVideoSettings(with: videoSettingsSubject, on: vc)
            })
            .disposed(by: disposeBag)
    }
    
    private func openVideoSettings(with settingsSubject: BehaviorSubject<VideoSettings>, on vc: UIViewController) {
        let viewModel = VideoSettingsViewModel(settingsSubject: settingsSubject)
        
        let viewController: VideoSettingsViewController = VideoSettingsViewController.createFromMainStoryboard()
        viewController.viewModel = viewModel
        
        let navController = UINavigationController(rootViewController: viewController)
        vc.present(navController, animated: true, completion: nil)
    }
}
