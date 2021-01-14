import Foundation
import RxSwift
import RealmSwift
import RxSwiftExt

class VideoUploader {
    static let shared = VideoUploader()
    
    let webServerAddress: Observable<ServerAddresses>
    let downloadAndProcessVideo: Observable<VideoEntity>
    var processingActivityIndicator: Observable<Bool> {
        processingActivityIndicatorSubject.asObservable()
    }
    
    private var stopServerWhenDownloadingCompleted = false
    private let processingActivityIndicatorSubject: BehaviorSubject<Bool>
    private var downloadAndProcessVideoDisposable: Disposable?
    private let realm: Realm

    init(
        webServer: LocalWebServer = LocalWebServer(),
        realm: Realm = try! Realm(),
        localStore: LocalDiskStore = LocalDiskStore()
    ) {
        self.realm = realm
        self.webServerAddress = webServer.address
        
        let videoUploaded = webServer.run()
            .share()
        
        let extractDataIndicator = ActivityIndicator()
        let dataExtracted = videoUploaded
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { video -> Single<VideoDataExtractor.VideoData> in
                VideoDataExtractor.extractData(from: video.videoPath)
                    .trackActivity(extractDataIndicator)
                    .asSingle()
            }
            .share()
        
        let temporaryVideo = Observable.zip(videoUploaded, dataExtracted) { video, data -> TemporaryVideo in
            TemporaryVideo(
                videoPath: video.videoPath,
                subtitleFilesPaths: video.subtitlePaths + data.extractedSubtitlesPaths,
                audioStreamNames: data.audioTracksTitles
            )
        }
        
        let saveVideoIndicator = ActivityIndicator()
        let videoSavedOnDisk = temporaryVideo
            .flatMap({ video -> Single<String> in
                localStore.save(video: video)
                    .trackActivity(saveVideoIndicator)
                    .asSingle()
            })
            .share()
        
        self.downloadAndProcessVideo = Observable.zip(videoSavedOnDisk, temporaryVideo) { directoryName, tempVideo -> VideoEntity in
            let videoEntity = VideoEntity()
            videoEntity.fileName = tempVideo.videoPath.lastPathComponent
            videoEntity.savedInDirectoryName = directoryName
            videoEntity.audioStreamNames.append(objectsIn: tempVideo.audioStreamNames)
            videoEntity.subtitleNames.append(objectsIn: tempVideo.subtitleFilesPaths.map({ $0.lastPathComponent }))
            return videoEntity
        }
        
        self.processingActivityIndicatorSubject = BehaviorSubject(value: false)
            
        let _ = Observable.combineLatest(LocalWebServerUploadConnection.activity, extractDataIndicator.asObservable(), saveVideoIndicator.asObservable())
            .map { $0 || $1 || $2 }
            .distinctUntilChanged()
            .bind(to: self.processingActivityIndicatorSubject)
    }
    
    func startDownloading() {
        stopServerWhenDownloadingCompleted = false
        if downloadAndProcessVideoDisposable != nil { return }
        
        downloadAndProcessVideoDisposable = downloadAndProcessVideo
            .observe(on: MainScheduler())
            .do(onError: { error in
                print(error)
            })
            .do(onDispose: {
                FileManager.clearTmpDirectory()
            })
            .do(afterNext: { [weak self] _ in
                guard let self = self else { return }
                if self.stopServerWhenDownloadingCompleted {
                    self.stopServer()
                }
            })
            .subscribe(realm.rx.add())
    }
    
    func closeWebServerIfNotLoading() {
        let isLoading = try! processingActivityIndicatorSubject.value()
        
        if !isLoading {
            stopServer()
        } else {
            stopServerWhenDownloadingCompleted = true
        }
    }
    
    private func stopServer() {
        self.downloadAndProcessVideoDisposable?.dispose()
        self.downloadAndProcessVideoDisposable = nil
    }
    
}
