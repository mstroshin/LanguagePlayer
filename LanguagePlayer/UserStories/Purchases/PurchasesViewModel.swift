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
        let buySubject = PublishSubject<Purchases.Package>()
        let restoreSubject = PublishSubject<Void>()
        let closeSubject = PublishSubject<Void>()
        
        self.input = Input(
            buy: buySubject.asObserver(),
            restore: restoreSubject.asObserver(),
            close: closeSubject.asObserver()
        )
        
        let activityIndicator = ActivityIndicator()
        
        let products = purchaseService.retrieveProductsInfo()
            .trackActivity(activityIndicator)
            .map({ packages -> Result<[Purchases.Package], Error> in
                .success(packages)
            })
            .asDriver { error -> Driver<Result<[Purchases.Package], Error>> in
                .just(.failure(error))
            }
        
        let buyingResult = buySubject
            .flatMap {
                purchaseService.buy(package: $0)
                    .trackActivity(activityIndicator)
                    .materialize()
            }
            .share()
            .asDriver(onErrorJustReturn: .next(()))
        let buyingError = buyingResult.compactMap { $0.error?.localizedDescription }
        
        let restoringResult = restoreSubject
            .flatMap {
                purchaseService.restorePurchases()
                    .trackActivity(activityIndicator)
                    .materialize()
            }
            .share()
            .asDriver(onErrorJustReturn: .next(false))
        let restoringError = restoringResult.compactMap { $0.error?.localizedDescription }
        
//        let restoringResultErased = restoringResult
//            .compactMap { $0.element }
//            .map { _ -> Result<Void, Error> in
//                Result.success(())
//            }
        
        let hasPremium = Driver.zip(buyingResult, restoringResult)
            .flatMap { _ -> Driver<Bool> in
                purchaseService.checkPremium()
                    .asDriver(onErrorJustReturn: false)
            }
//        let hasPremium = Driver.merge(buyingResult, restoringResultErased)
//            .flatMap { _ -> Driver<Bool> in
//                purchaseService.checkPremium()
//                    .asDriver(onErrorJustReturn: false)
//            }
            
        self.output = Output(
            products: products,
            buyingResult: buyingResult.compactMap { $0.element },
            restoringResult: restoringResult.compactMap { $0.element },
            activityIndicator: activityIndicator,
            hasPremium: Driver.merge(hasPremium, purchaseService.checkPremium().asDriver(onErrorJustReturn: false)),
            error: Driver.merge(restoringError, buyingError)
        )
        
        self.route = Route(
            close: closeSubject.asDriver(onErrorJustReturn: ())
        )
    }
    
}

extension PurchasesViewModel {
    
    struct Input {
        let buy: AnyObserver<Purchases.Package>
        let restore: AnyObserver<Void>
        let close: AnyObserver<Void>
    }
    
    struct Output {
        let products: Driver<Result<[Purchases.Package], Error>>
        let buyingResult: Driver<Void>
        let restoringResult: Driver<Bool>
        let activityIndicator: ActivityIndicator
        let hasPremium: Driver<Bool>
        let error: Driver<String>
    }
    
    struct Route {
        let close: Driver<Void>
    }
    
}
