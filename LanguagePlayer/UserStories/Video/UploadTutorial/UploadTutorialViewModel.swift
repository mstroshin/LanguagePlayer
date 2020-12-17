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
                VideoDataExtractor.extractData(from: video.videoPath)
            }
            .share()
        
        let temporaryVideo = Observable.zip(videoUploaded, dataExtracted) { video, data -> TemporaryVideo in
            TemporaryVideo(
                videoPath: video.videoPath,
                subtitleFilesPaths: video.subtitlePaths + data.extractedSubtitlesPaths,
                audioStreamNames: data.audioTracksTitles
            )
        }
        
        let videoSavedOnDisk = temporaryVideo
            .flatMap(localStore.save(video:))
            .share()
        
        let videoSavedInRealm = Observable.zip(videoSavedOnDisk, temporaryVideo) { directoryName, tempVideo -> VideoEntity in
            let videoEntity = VideoEntity()
            videoEntity.fileName = tempVideo.videoPath.lastPathComponent
            videoEntity.savedInDirectoryName = directoryName
            videoEntity.audioStreamNames.append(objectsIn: tempVideo.audioStreamNames)
            videoEntity.subtitleNames.append(objectsIn: tempVideo.subtitleFilesPaths.map({ $0.lastPathComponent }))
            return videoEntity
        }
        
        videoSavedInRealm
            .observeOn(MainScheduler())
            .do(onError: { error in
                print(error)
            })
            .do(onDispose: {
                FileManager.clearTmpDirectory()
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
