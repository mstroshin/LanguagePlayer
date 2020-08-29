import ReSwift
import Foundation

var store: Store<AppState>!

struct AppEnvironment {
    let store: Store<AppState>
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = AppState()
        
        let filestore = filestoreMiddleware(filestore: LocalDiskStore())
        let userDefaults = userDefaultsMiddleware(userDefaults: UserDefaultsDataStore())
        let translation = translationMiddleware(translationService: YandexTranslationService())
        let analytics = analyticsMiddleware()
        
        let store = Store(
            reducer: appStateReducer,
            state: appState,
            middleware: [translation, filestore, userDefaults, analytics],
            automaticallySkipsRepeats: true
        )
                
        return AppEnvironment(store: store)
    }
}

