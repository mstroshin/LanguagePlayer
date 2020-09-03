import ReSwift
import StoreKit

protocol PurchasingActions: Action {}

struct RestorePurchase: PurchasingActions {}

//
struct Purchase: PurchasingActions {
    let id: String
}

struct LoadingPurchase: PurchasingActions {}

struct PurchaseCompleted: PurchasingActions {
    let id: String
    let error: Error?
}

//
struct RetrieveProductsInfo: PurchasingActions {}

struct LoadingProductsInfo: PurchasingActions {}

struct LoadingProductsInfoError: PurchasingActions {
    let error: Error
}
//

struct SaveProductsInfo: PurchasingActions {
    let products: [SKProduct]
}
