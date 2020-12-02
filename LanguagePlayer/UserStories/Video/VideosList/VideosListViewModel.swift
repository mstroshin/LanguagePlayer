import Foundation
import RxSwift
import RealmSwift
import RxCocoa
import RxRealm

class VideosListViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
        
    private let disposeBag = DisposeBag()
    
    init(realm: Realm = try! Realm()) {
        //View inputs
        let openVideo = PublishSubject<Int>()
        let openUploadTutorial = PublishSubject<Void>()
        let removeVideo = PublishSubject<Int>()
        let removeVideoWithCards = PublishSubject<Int>()
        
        self.input = Input(
            openUploadTutorial: openUploadTutorial.asObserver(),
            openVideo: openVideo.asObserver(),
            removeVideo: removeVideo.asObserver(),
            removeVideoWithCards: removeVideoWithCards.asObserver()
        )
        
        //View outputs
        let realmVideoEntities = Observable.array(from: realm.objects(VideoEntity.self))
        
        let videoViewEntities = realmVideoEntities
            .map { $0.map(VideoViewEntity.init) }
            .asDriver(onErrorJustReturn: [])
        
        self.output = Output(
            videos: videoViewEntities
        )
        
        removeVideo
            .withLatestFrom(realmVideoEntities, resultSelector: { index, videos -> VideoEntity in
                videos[index]
            })
            .subscribe(realm.rx.delete())
            .disposed(by: disposeBag)
        
        removeVideoWithCards
            .do(afterNext: { index in
                removeVideo.onNext(index)
            })
            .withLatestFrom(realmVideoEntities, resultSelector: { index, videos -> VideoEntity in
                videos[index]
            })
            .map(\.translations)
            .subscribe(realm.rx.delete())
            .disposed(by: disposeBag)
        
        //Coordinator outputs
        let openVideoRoute = openVideo
            .withLatestFrom(realmVideoEntities, resultSelector: { index, videos -> VideoEntity in
                videos[index]
            })
        
        self.route = Route(
            openVideo: openVideoRoute,
            openUploadTutorial: openUploadTutorial.asObservable()
        )
    }
    
}

extension VideosListViewModel {
    
    struct Input {
        let openUploadTutorial: AnyObserver<Void>
        let openVideo: AnyObserver<Int>
        let removeVideo: AnyObserver<Int>
        let removeVideoWithCards: AnyObserver<Int>
    }
    
    struct Output {
        let videos: Driver<[VideoViewEntity]>
    }
    
    struct Route {
        let openVideo: Observable<VideoEntity>
        let openUploadTutorial: Observable<Void>
    }
    
}
