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
//        let transactions = transactionsMiddleware()
        let transactions = transactionsMiddleware(
            purchaseService: PurchaseService(productIds: PurchaseIds.all)
        )
        
        let store = Store(
            reducer: appStateReducer,
            state: appState,
            middleware: [translation, filestore, userDefaults, transactions, analytics],
            automaticallySkipsRepeats: true
        )
                
        return AppEnvironment(store: store)
    }
}

