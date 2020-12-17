import Foundation
import RxSwift
import RxCocoa

struct VideoSettings {
    let audioTrackTitles: [String]
    let subtitleTitles: [String]
    
    let audioStreamIndex: Int
    let firstSubIndex: Int
    let secondsSubIndex: Int
    
    init(audioTrackTitles: [String] = [],
         subtitleTitles: [String] = [],
         audioStreamIndex: Int = 0,
         firstSubIndex: Int = 0,
         secondsSubIndex: Int = 0) {
        self.audioTrackTitles = audioTrackTitles
        self.subtitleTitles = subtitleTitles
        self.audioStreamIndex = audioStreamIndex
        self.firstSubIndex = firstSubIndex
        self.secondsSubIndex = secondsSubIndex
    }
    
}

class VideoSettingsViewModel: ViewModel {
    let input: Input
    let output: Output
    private let disposeBag = DisposeBag()
    
    init(settingsSubject: BehaviorSubject<VideoSettings>) {
        let currentSettings = try! settingsSubject.value()
        let audioSelected = BehaviorSubject<Int>(value: currentSettings.audioStreamIndex)
        let firstSubtitleSelected = BehaviorSubject<Int>(value: currentSettings.firstSubIndex)
        let secondSubtitleSelected = BehaviorSubject<Int>(value: currentSettings.secondsSubIndex)
        
        self.input = Input(
            audioSelected: audioSelected.asObserver(),
            firstSubtitleSelected: firstSubtitleSelected.asObserver(),
            secondSubtitleSelected: secondSubtitleSelected.asObserver()
        )
        
        var subtitleTitles = ["Нет"]
        subtitleTitles.append(contentsOf: currentSettings.subtitleTitles)
        
        let changedSettings = Observable.combineLatest(audioSelected, firstSubtitleSelected, secondSubtitleSelected) {
            VideoSettings(
                audioTrackTitles: currentSettings.audioTrackTitles,
                subtitleTitles: currentSettings.subtitleTitles,
                audioStreamIndex: $0,
                firstSubIndex: $1,
                secondsSubIndex: $2
            )
        }.asDriver(onErrorJustReturn: VideoSettings())
        
        self.output = Output(
            audioTitles: currentSettings.audioTrackTitles,
            subtitleTitles: subtitleTitles,
            changedSettings: changedSettings
        )
        
        changedSettings
            .drive(settingsSubject)
            .disposed(by: disposeBag)
    }
    
}

extension VideoSettingsViewModel {
    
    struct Input {
        let audioSelected: AnyObserver<Int>
        let firstSubtitleSelected: AnyObserver<Int>
        let secondSubtitleSelected: AnyObserver<Int>
    }
    
    struct Output {
        let audioTitles: [String]
        let subtitleTitles: [String]
        
        let changedSettings: Driver<VideoSettings>
    }
    
}
