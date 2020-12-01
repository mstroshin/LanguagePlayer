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
        
        let subtitlesExtracted = videoSavedOnDisk
            .flatMap { video -> Single<[URL]> in
                SubtitlesExtractor().extract(filePath: video.videoUrl)
            }
                
        let videoSavedInRealm = Observable.zip(videoSavedOnDisk, subtitlesExtracted) { video, subUrls -> VideoEntity in
            video.extractedSubPaths.append(objectsIn: subUrls.map(\.absoluteString))
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
