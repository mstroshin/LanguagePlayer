import Foundation
import RxSwift
import RxCocoa
import Purchases
import RxSwiftExt

class PurchasesViewModel: ViewModel, ViewModelCoordinatable {
    let input: Input
    let output: Output
    let route: Route
        
    init(purchaseService: PurchaseService = PurchaseService()) {
        let retrieveProducts = PublishSubject<Void>()
        let buySubject = PublishSubject<Purchases.Package>()
        let restoreSubject = PublishSubject<Void>()
        let closeSubject = PublishSubject<Void>()
        let activityIndicator = ActivityIndicator()
        
        self.input = Input(
            retrieveProducts: retrieveProducts.asObserver(),
            buy: buySubject.asObserver(),
            restore: restoreSubject.asObserver(),
            close: closeSubject.asObserver()
        )
        
        let retrieveProductsInfo = retrieveProducts
            .skip(while: { PurchaseService.isPremium })
            .flatMap {
                purchaseService.retrieveProductsInfo()
                    .trackActivity(activityIndicator)
                    .materialize()
            }
            .share()
            .debug("retrieveProductsInfo", trimOutput: false)
        let retrieveProductsError = retrieveProductsInfo
            .compactMap { $0.error }
            .asDriver(onErrorJustReturn: NSError())
        
        let buyingResult = buySubject
            .flatMap {
                purchaseService.buy(package: $0)
                    .trackActivity(activityIndicator)
                    .materialize()
            }
            .share()
            .asDriver(onErrorJustReturn: .next(()))
        let buyingError = buyingResult.compactMap { $0.error }
        
        let restoringResult = restoreSubject
            .flatMap {
                purchaseService.restorePurchases()
                    .trackActivity(activityIndicator)
                    .materialize()
            }
            .share()
            .asDriver(onErrorJustReturn: .next(false))
        let restoringError = restoringResult.compactMap { $0.error }
        
        let hasPremium = Driver.zip(buyingResult, restoringResult)
            .flatMap { _ -> Driver<Bool> in
                purchaseService.checkPremium()
                    .asDriver(onErrorJustReturn: false)
            }
        
        let allErrors = Driver.merge(restoringError, buyingError, retrieveProductsError)
            .map { error -> PurchasesError in
                let error = error as NSError
                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                    switch underlyingError.code {
                        case NSURLErrorNotConnectedToInternet:
                            return .noInternet
                        default: break
                    }
                }
                switch Purchases.ErrorCode(_nsError: error).code {
                    case .networkError:
                        return .noInternet
                    case .purchaseCancelledError:
                        return .cancel
                    default:
                        return .other
                }
            }
        
        self.output = Output(
            products: retrieveProductsInfo.compactMap { $0.element }.asDriver(onErrorJustReturn: []),
            buyingResult: buyingResult.compactMap { $0.element },
            restoringResult: restoringResult.compactMap { $0.element },
            activityIndicator: activityIndicator,
            hasPremium: Driver.merge(hasPremium, purchaseService.checkPremium().asDriver(onErrorJustReturn: false)),
            error: allErrors
        )
        
        self.route = Route(
            close: closeSubject.asDriver(onErrorJustReturn: ())
        )
    }
    
}

extension PurchasesViewModel {
    
    enum PurchasesError: Error {
        case noInternet
        case cancel
        case other
    }
    
    struct Input {
        let retrieveProducts: AnyObserver<Void>
        let buy: AnyObserver<Purchases.Package>
        let restore: AnyObserver<Void>
        let close: AnyObserver<Void>
    }
    
    struct Output {
        let products: Driver<[Purchases.Package]>
        let buyingResult: Driver<Void>
        let restoringResult: Driver<Bool>
        let activityIndicator: ActivityIndicator
        let hasPremium: Driver<Bool>
        let error: Driver<PurchasesError>
    }
    
    struct Route {
        let close: Driver<Void>
    }
    
}
