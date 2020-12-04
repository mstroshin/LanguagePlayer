import Foundation
import RxSwift
import RealmSwift

class UploadTutorialViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
    private let disposeBag = DisposeBag()
    
    init(
        webServer: LocalWebServer = LocalWebServer(),
        realm: Realm = try! Realm(),
        localStore: LocalDiskStore = LocalDiskStore()
    ) {
        self.input = Input()
        self.output = Output(addresses: webServer.address)
                
        let videoSavedOnDisk = webServer.run()
            .flatMap(localStore.save(uploaded:))
            .ignoreErrors()
            .share()
        
        let dataExtracted = videoSavedOnDisk
            .flatMap { video -> Single<VideoDataExtractor.VideoData> in
                VideoDataExtractor().extractData(from: video.videoUrl)
            }
                
        let videoSavedInRealm = Observable.zip(videoSavedOnDisk, dataExtracted) { video, data -> VideoEntity in
            video.subtitleNames.append(objectsIn: data.subtitleNames)
            video.audioStreamNames.append(objectsIn: data.audioStreamNames)
            return video
        }.share()
        
        videoSavedInRealm
            .observeOn(MainScheduler())
            .subscribe(realm.rx.add())
            .disposed(by: disposeBag)
        
        self.route = Route(
            videoLoaded: videoSavedInRealm
        )
            
    }
}

extension UploadTutorialViewModel {
    
    struct Input {}
    
    struct Output {
        let addresses: Observable<ServerAddresses>
    }
    
    struct Route {
        let videoLoaded: Observable<VideoEntity>
    }
    
}
