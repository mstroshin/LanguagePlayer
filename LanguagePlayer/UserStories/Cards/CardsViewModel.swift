import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class CardsViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
    
    private let disposeBag = DisposeBag()
    
    
    init(realm: Realm = try! Realm()) {
        let subtitles = Observable.array(from: realm.objects(FavoriteSubtitle.self))
        
        let removeCard = PublishSubject<Int>()
        removeCard
            .withLatestFrom(subtitles) { $1[$0] }
            .subscribe(realm.rx.delete())
            .disposed(by: disposeBag)
        
        let playVideo = PublishSubject<Int>()
        
        self.input = Input(
            removeCard: removeCard.asObserver(),
            playVideo: playVideo.asObserver()
        )
        
        self.output = Output(
            cards: subtitles.asDriver(onErrorJustReturn: [])
        )
        
        let openVideo = playVideo
            .withLatestFrom(subtitles) { $1[$0] }
            .compactMap { subtitle -> (VideoEntity, Milliseconds)? in
                if let video = subtitle.owners.first {
                    return (video, subtitle.fromTime)
                }
                return nil
            }
        self.route = Route(
            openVideo: openVideo
        )
    }
    
}

extension CardsViewModel {
    
    struct Input {
        let removeCard: AnyObserver<Int>
        let playVideo: AnyObserver<Int>
    }
    
    struct Output {
        let cards: Driver<[FavoriteSubtitle]>
    }
    
    struct Route {
        let openVideo: Observable<(VideoEntity, Milliseconds)>
    }
    
}
