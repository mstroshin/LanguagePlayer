import Foundation
import RxSwift
import RxCocoa

class VideoPlayerViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
    
    private let sourceSubtitlesConvertor: SubtitlesConvertor?
    private let targetSubtitlesConvertor: SubtitlesConvertor?
    private let playerController: PlayerController
    private let video: VideoEntity
    private let disposeBag = DisposeBag()
    
    init(video: VideoEntity, sourceSubUrl: URL?, targetSubUrl: URL?) {
        self.video = video
        self.playerController = PlayerController(videoUrl: video.videoUrl)
        
        var sourceSubtitlesConvertor: SubtitlesConvertor? = nil
        if let subtitleUrl = sourceSubUrl {
            sourceSubtitlesConvertor = SubtitlesConvertorFromSrt(with: subtitleUrl)
        }
        self.sourceSubtitlesConvertor = sourceSubtitlesConvertor
        
        var targetSubtitlesConvertor: SubtitlesConvertor? = nil
        if let targetSubUrl = targetSubUrl {
            targetSubtitlesConvertor = SubtitlesConvertorFromSrt(with: targetSubUrl)
        }
        self.targetSubtitlesConvertor = targetSubtitlesConvertor
        
        //Inputs
        let close = PublishSubject<Void>()
        let backwardSub = PublishSubject<Void>()
        let forwardSub = PublishSubject<Void>()
        
        self.input = Input(
            close: close.asObserver(),
            seek: self.playerController.seek,
            isPlaying: self.playerController.isPlaying,
            backwardSub: backwardSub.asObserver(),
            forwardSub: forwardSub.asObserver()
        )
        
        //Outputs
        var currentSubtitlesDriver: Driver<DoubleSubtitles>? = nil
        if let sourceConverter = sourceSubtitlesConvertor {
            currentSubtitlesDriver = self.playerController.currentTime
                .map { time -> DoubleSubtitles in
                    let source = sourceConverter.getSubtitle(for: time)
                    let target = targetSubtitlesConvertor?.getSubtitle(for: time)
                    return DoubleSubtitles(source: source, target: target)
                }
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: DoubleSubtitles(source: nil, target: nil))
        }
        
        self.output = Output(
            currentTime: self.playerController.currentTime.asDriver(onErrorJustReturn: 0),
            currentSubtitles: currentSubtitlesDriver,
            playerStatus: self.playerController.status.asDriver(onErrorJustReturn: .pause)
        )
        
        //Routes
        self.route = Route(
            close: close.asObservable()
        )
        
        //Maps
        backwardSub
            .compactMap { () -> Milliseconds? in
                let time = try! self.playerController.currentTime.value()
                if let subtitle = self.sourceSubtitlesConvertor?.getPreviousSubtitle(current: time) {
                    return subtitle.fromTime - 50
                } else {
                    return nil
                }
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        forwardSub
            .compactMap { () -> Milliseconds? in
                let time = try! self.playerController.currentTime.value()
                if let subtitle = self.sourceSubtitlesConvertor?.getNextSubtitle(current: time) {
                    return subtitle.fromTime - 50
                } else {
                    return nil
                }
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
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
    }
    
    struct Output {
        let currentTime: Driver<Milliseconds>
        let currentSubtitles: Driver<DoubleSubtitles>?
        let playerStatus: Driver<PlayerStatus>
    }
    
    struct Route {
        let close: Observable<Void>
    }
    
}
