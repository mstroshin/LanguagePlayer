import Foundation
import RxSwift
import RealmSwift

class UploadTutorialViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
    
    private let videoUploader: VideoUploader
    
    
    init(
        videoUploader: VideoUploader = VideoUploader.shared,
        realm: Realm = try! Realm(),
        localStore: LocalDiskStore = LocalDiskStore()
    ) {
        self.videoUploader = videoUploader
        
        self.input = Input()
        self.output = Output(
            addresses: videoUploader.webServerAddress,
            loading: videoUploader.processingActivityIndicator
        )
        
        videoUploader.startDownloading()
        
        self.route = Route(
            videoLoaded: videoUploader.downloadAndProcessVideo
        )
    }
    
    deinit {
        videoUploader.closeWebServerIfNotLoading()
    }
}

extension UploadTutorialViewModel {
    
    struct Input {}
    
    struct Output {
        let addresses: Observable<ServerAddresses>
        let loading: Observable<Bool>
    }
    
    struct Route {
        let videoLoaded: Observable<VideoEntity>
    }
    
}
