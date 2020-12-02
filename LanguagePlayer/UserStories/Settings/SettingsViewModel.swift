import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

class SettingsViewModel: ViewModel {
    let input: Input
    let output: Output
    
    private let settingsShared = SettingsSharedModel.shared
    
    init() {
        self.input = Input()
        self.output = Output()
    }
    
}

extension SettingsViewModel {
    
    struct Input {
//        let openPremium: AnyObserver<Void>
//        let selectSourceLanguage: AnyObserver<Void>
//        let selectTargetLanguage: AnyObserver<Void>
//        let downloadOfflineLanguages: AnyObserver<Void>
    }
    
    struct Output {
//        let isPremium: Driver<Bool>
//        let selectedSourceLanguage: Driver<String>
//        let selectedTargetLanguage: Driver<String>
//        let isOfflineLanguagesDownloaded: Driver<Bool>
    }
    
}
