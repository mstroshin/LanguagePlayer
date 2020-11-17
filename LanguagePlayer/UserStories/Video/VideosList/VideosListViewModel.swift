import Foundation
import RxSwift
import RealmSwift

class VideosListViewModel {
    private let realm = try! Realm()
    private var videosResultChangeToken: NotificationToken?
    
    let videos = BehaviorSubject<[VideoEntity]>(value: [])
    
    init() {
        
    }
    
    func viewDidLoad() {
        let videosResult = realm.objects(VideoEntity.self)
        videosResultChangeToken = videosResult.observe { change in
            switch change {
            case .initial(let videosEntities):
                self.videos.onNext(Array(videosEntities))
            case .update(let videosEntities, _, _, _):
                self.videos.onNext(Array(videosEntities))
            case .error(_):
                break
            }
        }
    }
    
    func itemSelected(indexPath: IndexPath) {
        let video = try! videos.value()[indexPath.row]
        
        let videoPlayerVC: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
        
        let viewModel = VideoPlayerViewModel(vc: videoPlayerVC, video: video)
        videoPlayerVC.viewModel = viewModel
        
        videoPlayerVC.modalPresentationStyle = .fullScreen
//        viewController?.present(videoPlayerVC, animated: true, completion: nil)
    }
    
    func addVideoPressed() {
        let vc: UploadTutorialViewController = UploadTutorialViewController.createFromMainStoryboard()
//        viewController?.present(vc, animated: true, completion: nil)
    }
    
    func removeVideo(indexPath: IndexPath, removeAllCards: Bool) {
        let video = try! videos.value()[indexPath.row]
        
        try! realm.write {
            if removeAllCards {
                realm.delete(video.translations)
            }
            
            realm.delete(video)
        }
    }
    
}
