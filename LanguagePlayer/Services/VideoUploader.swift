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
        dataExtractor: VideoDataExtractor = VideoDataExtractor(),
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
                dataExtractor.extractData(from: video.videoPath)
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
        .share()
        
        let saveVideoIndicator = ActivityIndicator()
        let videoSavedOnDisk = temporaryVideo
            .flatMap({ video -> Single<String> in
                localStore.save(video: video)
                    .trackActivity(saveVideoIndicator)
                    .asSingle()
            })
        
        self.downloadAndProcessVideo = Observable.zip(videoSavedOnDisk, temporaryVideo) { directoryName, tempVideo -> VideoEntity in
            let videoEntity = VideoEntity()
            videoEntity.fileName = tempVideo.videoPath.lastPathComponent
            videoEntity.savedInDirectoryName = directoryName
            videoEntity.audioStreamNames.append(objectsIn: tempVideo.audioStreamNames)
            videoEntity.subtitleNames.append(objectsIn: tempVideo.subtitleFilesPaths.map({ $0.lastPathComponent }))
            return videoEntity
        }
        
        self.processingActivityIndicatorSubject = BehaviorSubject(value: false)
            
        let _ = Observable.combineLatest(
                LocalWebServerUploadConnection.activity,
                extractDataIndicator.asObservable(),
                saveVideoIndicator.asObservable()
            )
            .map { $0 || $1 || $2 }
            .distinctUntilChanged()
            .bind(to: self.processingActivityIndicatorSubject)
    }
    
    func startWebServer() {
        stopServerWhenDownloadingCompleted = false
        if downloadAndProcessVideoDisposable != nil { return }
        
        downloadAndProcessVideoDisposable = downloadAndProcessVideo
            .observe(on: MainScheduler())
            .do(onError: { [weak self] error in
                print(error)
                self?.stopServerIfNotLoading()
            })
            .do(onDispose: {
                FileManager.clearTmpDirectory()
            })
            .do(afterNext: { [weak self] _ in
                self?.stopServerIfNotLoading()
            })
            .subscribe(realm.rx.add())
    }
    
    func stopWebServer() {
        let isLoading = try! processingActivityIndicatorSubject.value()
        
        if !isLoading {
            stopServer()
        } else {
            stopServerWhenDownloadingCompleted = true
        }
    }
    
    private func stopServerIfNotLoading() {
        if stopServerWhenDownloadingCompleted {
            stopServer()
        }
    }
    
    private func stopServer() {
        self.downloadAndProcessVideoDisposable?.dispose()
        self.downloadAndProcessVideoDisposable = nil
    }
    
}
