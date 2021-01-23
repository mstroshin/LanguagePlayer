import Foundation
import RxSwift
import RxCocoa

class UploadTutorialViewModel: ViewModel {
    private let videoBackgroundSaver: VideoBackgroundSaver
    
    init(
        videoBackgroundSaver: VideoBackgroundSaver = VideoBackgroundSaver.shared
    ) {
        self.videoBackgroundSaver = videoBackgroundSaver
        videoBackgroundSaver.disposeIfInactive = false
    }
    
    func transform(input: Input) -> Output {
        Output(
            addresses: videoBackgroundSaver.addresses.asDriver(onErrorJustReturn: ServerAddresses.empty),
            loading: videoBackgroundSaver.activityIndicator.asSharedSequence()
        )
    }
    
    deinit {
        videoBackgroundSaver.disposeIfInactive = true
    }
}

extension UploadTutorialViewModel {
    
    struct Input {}
    
    struct Output {
        let addresses: Driver<ServerAddresses>
        let loading: Driver<Bool>
    }
    
}
