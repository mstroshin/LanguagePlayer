import Foundation
import RxSwift
import RealmSwift

class VideoBackgroundSaver {
    static let shared = VideoBackgroundSaver()
    
    let addresses: Observable<ServerAddresses>
    let activityIndicator = ActivityIndicator()
    var disposeIfInactive = false {
        didSet {
            if disposeIfInactive && !isActive {
                disposeSaving()
            }
        }
    }
    
    private let videoDownloader: VideoDownloader
    private let realm: Realm
    private let fileStore: LocalDiskStore
    private var savingDisposable: Disposable?
    private var indicatorDisposable: Disposable?
    private var isActive = false
    
    init(
        videoDownloader: VideoDownloader = VideoDownloader(),
        realm: Realm = defaultRealm,
        fileStore: LocalDiskStore = DefaultLocalDiskStore()
    ) {
        self.addresses = videoDownloader.addresses
        self.videoDownloader = videoDownloader
        self.realm = realm
        self.fileStore = fileStore
    }
    
    func downloadAndSaveVideo() -> ActivityIndicator {
        if savingDisposable != nil {
            return activityIndicator
        }
        
        self.savingDisposable = videoDownloader.downloadAndProcessVideo
            .flatMap { videoData -> Single<String> in
                //Move files from tmp directory to documents directory
                let directoryName = UUID().uuidString
                let pathsToMove = videoData.subtitleFilesPaths + [videoData.videoPath]
                let moves = pathsToMove.map { path -> Single<Void> in
                    self.fileStore.moveFileInDocuments(fromPath: path, subdirectoryName: directoryName)
                }
                
                return Single.zip(moves)
                    .flatMap { _ in Single<String>.just(directoryName) }
            }
            .withLatestFrom(videoDownloader.downloadAndProcessVideo) { directory, videoData -> Video in
                Video(
                    id: UUID().uuidString,
                    name: URL(fileURLWithPath: videoData.videoPath).lastPathComponent,
                    path: videoData.videoPath,
                    savedInDirectoryName: directory,
                    thumbneilImagePath: videoData.thumbnailImagePath,
                    subtitlePaths: videoData.subtitleFilesPaths,
                    audioTrackNames: videoData.audioStreamNames,
                    favoriteCards: []
                )
            }
            .map(VideoEntity.from(dto:))
            .trackActivity(activityIndicator)
            .subscribe(realm.rx.add())
        
        self.indicatorDisposable = activityIndicator
            .drive(onNext: { [weak self] isActive in
                guard let self = self else { return }
                self.isActive = isActive
                if !isActive && self.disposeIfInactive {
                    self.disposeSaving()
                }
            })
        
        return activityIndicator
    }
    
    private func disposeSaving() {
        savingDisposable?.dispose()
        savingDisposable = nil
    }
    
}
