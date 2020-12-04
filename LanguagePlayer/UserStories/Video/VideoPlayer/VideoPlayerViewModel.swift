import Foundation
import RxSwift
import RxCocoa

class VideoPlayerViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
    
    let video: VideoEntity
    let videoSettings = BehaviorSubject<VideoSettings>(value: VideoSettings.zero)
    
    private let playerController: PlayerController
    private let disposeBag = DisposeBag()
    
    init(video: VideoEntity) {
        self.video = video
        self.playerController = PlayerController(videoUrl: video.videoUrl)
        
        let firstSubtitlesConvertor: SubtitlesConvertor = SubtitlesConvertorFromSrt()
        let secondSubtitlesConvertor: SubtitlesConvertor = SubtitlesConvertorFromSrt()
        
        //Inputs
        let close = PublishSubject<Void>()
        let backwardSub = PublishSubject<Void>()
        let forwardSub = PublishSubject<Void>()
        let backwardFifteen = PublishSubject<Void>()
        let forwardFifteen = PublishSubject<Void>()
                
        self.input = Input(
            close: close.asObserver(),
            seek: self.playerController.seek,
            isPlaying: self.playerController.isPlaying,
            backwardSub: backwardSub.asObserver(),
            forwardSub: forwardSub.asObserver(),
            backwardFifteen: backwardFifteen.asObserver(),
            forwardFifteen: forwardFifteen.asObserver(),
            changedVideoSettings: videoSettings.asObserver()
        )
        
        //Outputs
        let currentSubtitlesDriver = self.playerController.currentTime
            .map { time -> DoubleSubtitles in
                let source = firstSubtitlesConvertor.getSubtitle(for: time)
                let target = secondSubtitlesConvertor.getSubtitle(for: time)
                return DoubleSubtitles(source: source, target: target)
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: DoubleSubtitles(source: nil, target: nil))
        
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
            .compactMap { [weak self] () -> Milliseconds? in
                guard let self = self else { return nil }
                let time = try! self.playerController.currentTime.value()
                if let subtitle = firstSubtitlesConvertor.getPreviousSubtitle(current: time) {
                    return subtitle.fromTime - 50
                } else {
                    return nil
                }
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        forwardSub
            .compactMap { [weak self] () -> Milliseconds? in
                guard let self = self else { return nil }
                let time = try! self.playerController.currentTime.value()
                if let subtitle = firstSubtitlesConvertor.getNextSubtitle(current: time) {
                    return subtitle.fromTime - 50
                } else {
                    return nil
                }
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        backwardFifteen
            .map { [weak self] in
                guard let self = self else { return 0 }
                let time = try! self.playerController.currentTime.value()
                return time - 15 * 1000
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        forwardFifteen
            .map { [weak self] in
                guard let self = self else { return 0 }
                let time = try! self.playerController.currentTime.value()
                return time + 15 * 1000
            }
            .bind(to: self.playerController.seek)
            .disposed(by: disposeBag)
        
        videoSettings
            .map(\.audioStreamIndex)
            .distinctUntilChanged()
            .bind(to: self.playerController.audioStream)
            .disposed(by: disposeBag)
        
        videoSettings
            .map(\.firstSubIndex)
            .map { $0 <= 0 ? -1 : $0 - 1 } //cuz 0 is disable subtitle (-1)
            .distinctUntilChanged()
            .compactMap(video.subtitleUrl(for:))
            .subscribe(onNext: { subUrl in
                firstSubtitlesConvertor.prepareParts(from: subUrl)
            })
            .disposed(by: disposeBag)
        
        videoSettings
            .map(\.secondsSubIndex)
            .map { $0 <= 0 ? -1 : $0 - 1 } //cuz 0 is disable subtitle (-1)
            .distinctUntilChanged()
            .compactMap(video.subtitleUrl(for:))
            .subscribe(onNext: { subUrl in
                secondSubtitlesConvertor.prepareParts(from: subUrl)
            })
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
        let backwardFifteen: AnyObserver<Void>
        let forwardFifteen: AnyObserver<Void>
        let changedVideoSettings: AnyObserver<VideoSettings>
    }
    
    struct Output {
        let currentTime: Driver<Milliseconds>
        let currentSubtitles: Driver<DoubleSubtitles>
        let playerStatus: Driver<PlayerStatus>
    }
    
    struct Route {
        let close: Observable<Void>
    }
    
}
