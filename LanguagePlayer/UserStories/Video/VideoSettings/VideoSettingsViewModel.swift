import Foundation
import RxSwift
import RxCocoa

struct VideoSettings {
    let audioStreamIndex: Int
    let firstSubIndex: Int
    let secondsSubIndex: Int
    
    static var zero: VideoSettings {
        VideoSettings(audioStreamIndex: 0, firstSubIndex: 0, secondsSubIndex: 0)
    }
}

class VideoSettingsViewModel: ViewModel {
    let input: Input
    let output: Output
    
    init(video: VideoEntity, currentSettings: VideoSettings) {
        let audioSelected = BehaviorSubject<Int>(value: currentSettings.audioStreamIndex)
        let firstSubtitleSelected = BehaviorSubject<Int>(value: currentSettings.firstSubIndex)
        let secondSubtitleSelected = BehaviorSubject<Int>(value: currentSettings.secondsSubIndex)
        
        self.input = Input(
            audioSelected: audioSelected.asObserver(),
            firstSubtitleSelected: firstSubtitleSelected.asObserver(),
            secondSubtitleSelected: secondSubtitleSelected.asObserver()
        )
        
        var subtitleTitles = ["Нет"]
        subtitleTitles.append(contentsOf: video.subtitleNames)
        
        let changedSettings = Observable.combineLatest(audioSelected, firstSubtitleSelected, secondSubtitleSelected) {
            VideoSettings(audioStreamIndex: $0, firstSubIndex: $1, secondsSubIndex: $2)
        }.asDriver(onErrorJustReturn: VideoSettings.zero)
        
        self.output = Output(
            audioTitles: Array(video.audioStreamNames),
            subtitleTitles: subtitleTitles,
            changedSettings: changedSettings
        )
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
