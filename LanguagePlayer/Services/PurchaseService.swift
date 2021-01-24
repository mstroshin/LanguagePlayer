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
                    let error = NSError(domain: "Unknow retrieving products error", code: 1, userInfo: nil)
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func buy(package: Purchases.Package) -> Single<Void> {
        Single.create { single -> Disposable in
            Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
                if (purchaserInfo?.entitlements.active.isEmpty ?? true) == false {
                    single(.success(()))
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
    
    func restorePurchases() -> Single<Bool> {
        Single.create { single -> Disposable in
            Purchases.shared.restoreTransactions { (purchaserInfo, error) in
                if let error = error {
                    single(.failure(error))
                } else if let purchaserInfo = purchaserInfo {
                    single(.success(!purchaserInfo.activeSubscriptions.isEmpty))
                } else {
                    let error = NSError(domain: "Unknow restoring error", code: 1, userInfo: nil)
                    single(.failure(error))
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
                    print("PREMIUM \(PurchaseService.isPremium)")
                    single(.success(PurchaseService.isPremium))
                } else if let error = error {
                    single(.failure(error))
                } else {
                    let error = NSError(domain: "Unknow checking premium error", code: 1, userInfo: nil)
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
}
