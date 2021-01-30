import Foundation
import RxSwift
import RealmSwift
import Reachability
import RxCocoa

class UploadTutorialViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
    
    private let videoUploader: VideoUploader
    private let disposeBag = DisposeBag()
    
    init(
        videoUploader: VideoUploader = VideoUploader.shared,
        realm: Realm = try! Realm(),
        localStore: LocalDiskStore = LocalDiskStore()
    ) {
        self.videoUploader = videoUploader
        let startServer = PublishSubject<Void>()
        let errorSubject = PublishSubject<UploadError>()
        
        startServer.flatMap { checkReachibility(connectionType: .wifi) }
            .subscribe(onNext: { wifi in
                if wifi {
                    videoUploader.startWebServer()
                } else {
                    errorSubject.onNext(.noWifi)
                }
            })
            .disposed(by: disposeBag)
        
        self.input = Input(
            startServer: startServer.asObserver()
        )
        self.output = Output(
            addresses: videoUploader.webServerAddress,
            loading: videoUploader.processingActivityIndicator,
            error: errorSubject.asDriver(onErrorJustReturn: .other)
        )
        
        self.route = Route(
            videoLoaded: videoUploader.downloadAndProcessVideo
        )
    }
    
    deinit {
        videoUploader.stopWebServer()
    }
}

extension UploadTutorialViewModel {
    
    enum UploadError: Error {
        case noWifi
        case other
    }
    
    struct Input {
        let startServer: AnyObserver<Void>
    }
    
    struct Output {
        let addresses: Observable<ServerAddresses>
        let loading: Observable<Bool>
        let error: Driver<UploadError>
    }
    
    struct Route {
        let videoLoaded: Observable<VideoEntity>
    }
    
}

func checkReachibility(connectionType: Reachability.Connection) -> Observable<Bool> {
    Observable.create { observer -> Disposable in
        let reachability = try! Reachability()

        reachability.whenReachable = { reachability in
            observer.onNext(reachability.connection == connectionType)
            observer.onCompleted()
        }
        reachability.whenUnreachable = { _ in
            observer.onNext(false)
            observer.onCompleted()
        }
        try! reachability.startNotifier()
        
        return Disposables.create {
            reachability.stopNotifier()
        }
    }
}
