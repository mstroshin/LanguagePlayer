import UIKit
import RxSwift

class VideoCoordinator: BaseCoordinator<Void> {
    private let videoListViewController: UIViewController
    
    init(videoListViewController: UIViewController) {
        self.videoListViewController = videoListViewController
    }
    
    override func start() -> Observable<Void> {
        return .never()
    }
}
