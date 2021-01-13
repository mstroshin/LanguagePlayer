import Foundation
import Purchases
import RxSwift

class PurchaseService {
    static var isPremium = false
    
    func retrieveProductsInfo() -> Single<[Purchases.Package]> {
        Single.create { single -> Disposable in
            Purchases.shared.offerings { (offerings, error) in
                if let packages = offerings?.current?.availablePackages {
                    single(.success(packages))
                } else if let error = error {
                    single(.failure(error))
                } else {
                    let error = NSError(domain: "Unknow purchasing error", code: 1, userInfo: nil)
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func buy(package: Purchases.Package) -> Completable {
        Completable.create { completable -> Disposable in
            Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
                if purchaserInfo?.entitlements[package.identifier]?.isActive == true {
                    completable(.completed)
                } else if let error = error {
                    completable(.error(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func restorePurchases() -> Single<[String]> {
        Single.create { single -> Disposable in
            Purchases.shared.restoreTransactions { (purchaserInfo, error) in
                if let error = error {
                    single(.failure(error))
                } else if let purchaserInfo = purchaserInfo {
                    single(.success(Array(purchaserInfo.activeSubscriptions)))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func checkPremium() -> Single<Bool> {
        Single.create { single -> Disposable in
            Purchases.shared.purchaserInfo { (purchaserInfo, error) in
                if let info = purchaserInfo {
                    PurchaseService.isPremium = !info.entitlements.active.isEmpty
                    single(.success(PurchaseService.isPremium))
                } else if let error = error {
                    single(.failure(error))
                } else {
                    let error = NSError(domain: "Unknow purchasing error", code: 1, userInfo: nil)
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
}
