import ReSwift
import StoreKit

protocol PurchasingActions: Action {}

struct RestorePurchase: PurchasingActions {}

struct Purchase: PurchasingActions {
    let id: String
}

struct PurchaseCompleted: PurchasingActions {
    let id: String
    let error: Error?
}

struct RetrieveProductsInfo: PurchasingActions {}

struct SaveProductsInfo: PurchasingActions {
    let products: [SKProduct]
}
