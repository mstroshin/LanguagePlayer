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
                
        let videoUploaded = webServer.run()
            .share()
        
        let dataExtracted = videoUploaded
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { video -> Single<VideoDataExtractor.VideoData> in
                VideoDataExtractor.extractData(from: video.video.temporaryDataPath)
            }
            .share()
        
        let temporaryVideo = Observable.zip(videoUploaded, dataExtracted) { video, data -> TemporaryVideo in
            TemporaryVideo(
                uploadedVideo: video,
                subtitleNames: data.subtitleNames + video.subtitles.map(\.fileName),
                audioStreamNames: data.audioStreamNames
            )
        }
        
        let videoSavedOnDisk = temporaryVideo
            .map(\.uploadedVideo)
            .flatMap(localStore.save(uploaded:))
            .share()
                
        let videoSavedInRealm = Observable.zip(videoSavedOnDisk, temporaryVideo) { directoryName, tempVideo -> VideoEntity in
            let videoEntity = VideoEntity()
            videoEntity.fileName = tempVideo.uploadedVideo.video.fileName
            videoEntity.savedInDirectoryName = directoryName
            videoEntity.audioStreamNames.append(objectsIn: tempVideo.audioStreamNames)
            videoEntity.subtitleNames.append(objectsIn: tempVideo.subtitleNames)
            
            return videoEntity
        }
        
        videoSavedInRealm
            .observeOn(MainScheduler())
            .do(onError: { error in
                print(error)
            })
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
