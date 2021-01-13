import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

class VideoPlayerViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
        
    private let playerController: PlayerController
    private let disposeBag = DisposeBag()
    
    init(
        video: VideoEntity,
        playerController: PlayerController,
        startingTime: Milliseconds? = nil,
        realm: Realm = try! Realm()
    ) {
        self.playerController = playerController
        
        let settings = VideoSettings(
            audioTrackTitles: Array(video.audioStreamNames),
            subtitleTitles: Array(video.subtitleNames)
        )
        let videoSettings = BehaviorSubject<VideoSettings>(value: settings)
        
        if let time = startingTime {
            playerController.status
                .filter {
                    if case PlayerStatus.ready(_) = $0 {
                        return true
                    } else {
                        return false
                    }
                }
                .take(1)
                .map { _ in time }
                .bind(to: self.playerController.seek)
                .disposed(by: disposeBag)
        }
        
        let firstSubtitlesConvertor: SubtitlesConvertor = SubtitlesConvertorFromSrt()
        let secondSubtitlesConvertor: SubtitlesConvertor = SubtitlesConvertorFromSrt()
        
        //Inputs
        let close = PublishSubject<Void>()
        let backwardSub = PublishSubject<Void>()
        let forwardSub = PublishSubject<Void>()
        let backwardFifteen = PublishSubject<Void>()
        let forwardFifteen = PublishSubject<Void>()
        let addToFavorite = PublishSubject<Void>()
        let openVideoSettings = PublishSubject<Void>()
        
        //Outputs
        let currentTimeSubtitles = self.playerController.currentTime
            .map { time -> DoubleSubtitles in
                let first = firstSubtitlesConvertor.getSubtitle(for: time)
                let second = secondSubtitlesConvertor.getSubtitle(for: time)
                let isFavorite = video.favoriteSubtitles.filter({ $0.first == first?.text }).first != nil
                
                return DoubleSubtitles(source: first, target: second, addedToFavorite: isFavorite)
            }
            .distinctUntilChanged()
        
        let favoriteChanged = addToFavorite
            .withLatestFrom(currentTimeSubtitles)
            .map {
                return DoubleSubtitles(
                    source: $0.source,
                    target: $0.target,
                    addedToFavorite: !$0.addedToFavorite
                )
            }
            .filter { $0.source != nil && $0.target != nil }
            .do(onNext: { subtitles in
                if subtitles.addedToFavorite {
                    let favorite = FavoriteSubtitle()
                    favorite.first = subtitles.source!.text
                    favorite.second = subtitles.target!.text
                    favorite.fromTime = subtitles.source!.fromTime
                    
                    try! realm.write {
                        video.favoriteSubtitles.append(favorite)
                    }
                } else if let index = video.favoriteSubtitles.firstIndex(where: { $0.first == subtitles.source?.text }) {
                    try! realm.write {
                        realm.delete(video.favoriteSubtitles[index])
                    }
                }
            })
        
        let currentSubtitlesDriver = Observable.merge([currentTimeSubtitles, favoriteChanged])
            .asDriver(onErrorJustReturn: DoubleSubtitles())
        
        //Routes
        let openVideoSettingsRoute = openVideoSettings
            .flatMap { _ -> Observable<BehaviorSubject<VideoSettings>> in
                return .just(videoSettings)
            }
        
        //Maps
        backwardSub
            .compactMap { () -> Milliseconds? in
                let time = try! playerController.currentTime.value()
                if let subtitle = firstSubtitlesConvertor.getPreviousSubtitle(current: time) {
                    return subtitle.fromTime - 50
                } else {
                    return nil
                }
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        forwardSub
            .compactMap { () -> Milliseconds? in
                let time = try! playerController.currentTime.value()
                if let subtitle = firstSubtitlesConvertor.getNextSubtitle(current: time) {
                    return subtitle.fromTime - 50
                } else {
                    return nil
                }
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        backwardFifteen
            .map {
                let time = try! playerController.currentTime.value()
                return time - 15 * 1000
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        forwardFifteen
            .map {
                let time = try! playerController.currentTime.value()
                return time + 15 * 1000
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        //Video Settings
        videoSettings
            .map(\.audioStreamIndex)
            .distinctUntilChanged()
            .bind(to: self.playerController.audioStream)
            .disposed(by: disposeBag)
        
        videoSettings
            .map(\.firstSubIndex)
            .map { $0 <= 0 ? -1 : $0 - 1 } //cuz 0 disables subtitle (-1)
            .distinctUntilChanged()
            .compactMap(video.subtitleUrl(for:))
            .subscribe(onNext: { subUrl in
                firstSubtitlesConvertor.prepareParts(from: subUrl)
            })
            .disposed(by: disposeBag)
        
        videoSettings
            .map(\.secondsSubIndex)
            .map { $0 <= 0 ? -1 : $0 - 1 } //cuz 0 disables subtitle (-1)
            .distinctUntilChanged()
            .compactMap(video.subtitleUrl(for:))
            .subscribe(onNext: { subUrl in
                secondSubtitlesConvertor.prepareParts(from: subUrl)
            })
            .disposed(by: disposeBag)
        
        //ViewModel
        self.input = Input(
            close: close.asObserver(),
            seek: self.playerController.seek,
            isPlaying: self.playerController.isPlaying,
            backwardSub: backwardSub.asObserver(),
            forwardSub: forwardSub.asObserver(),
            backwardFifteen: backwardFifteen.asObserver(),
            forwardFifteen: forwardFifteen.asObserver(),
            changedVideoSettings: videoSettings.asObserver(),
            addToFavorite: addToFavorite.asObserver(),
            openVideoSettings: openVideoSettings.asObserver()
        )
        
        self.output = Output(
            currentTime: self.playerController.currentTime.asDriver(onErrorJustReturn: 0),
            currentSubtitles: currentSubtitlesDriver,
            playerStatus: self.playerController.status.asDriver(onErrorJustReturn: .pause)
        )
        
        self.route = Route(
            close: close.asObservable(),
            openVideoSettings: openVideoSettingsRoute.asObservable()
        )
    }
    
    func set(viewport: UIView) {
        playerController.set(viewport: viewport)
    }
    
}

extension VideoPlayerViewModel {
    
    struct Input {
        let close: AnyObserver<Void>
        let seek: AnyObserver<Milliseconds>
        let isPlaying: AnyObserver<Bool>
        let backwardSub: AnyObserver<Void>
        let forwardSub: AnyObserver<Void>
        let backwardFifteen: AnyObserver<Void>
        let forwardFifteen: AnyObserver<Void>
        let changedVideoSettings: AnyObserver<VideoSettings>
        let addToFavorite: AnyObserver<Void>
        let openVideoSettings: AnyObserver<Void>
    }
    
    struct Output {
        let currentTime: Driver<Milliseconds>
        let currentSubtitles: Driver<DoubleSubtitles>
        let playerStatus: Driver<PlayerStatus>
    }
    
    struct Route {
        let close: Observable<Void>
        let openVideoSettings: Observable<BehaviorSubject<VideoSettings>>
    }
    
}
