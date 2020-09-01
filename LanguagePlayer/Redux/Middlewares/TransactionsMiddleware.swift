import ReSwift
import SwiftyStoreKit

func transactionsMiddleware() -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case let action as Purchase:
                    SwiftyStoreKit.purchaseProduct(action.id) { result in
                        switch result {
                        case .success(let purchase):
                            next(PurchaseCompleted(id: purchase.productId, error: nil))
                            
                        case .error(let error):
                            switch error.code {
                            case .unknown: print("Unknown error. Please contact support")
                            case .clientInvalid: print("Not allowed to make the payment")
                            case .paymentCancelled: break
                            case .paymentInvalid: print("The purchase identifier was invalid")
                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                            default: print((error as NSError).localizedDescription)
                            }
                            next(PurchaseCompleted(id: action.id, error: error))
                        }
                    }
                    
                case _ as RestorePurchase:
                    SwiftyStoreKit.restorePurchases(atomically: true) { results in
                        if results.restoreFailedPurchases.count > 0 {
                            print("Restore Failed: \(results.restoreFailedPurchases)")
                        }
                        else if results.restoredPurchases.count > 0 {
                            print("Restore Success: \(results.restoredPurchases)")
                        }
                        else {
                            print("Nothing to Restore")
                        }
                    }
                    
                case _ as RetrieveProductsInfo:
                    SwiftyStoreKit.retrieveProductsInfo(PurchaseIds.all) { result in
                        if result.retrievedProducts.isEmpty == false {
                            next(SaveProductsInfo(products: result.retrievedProducts))
                        } else {
                            if let invalidProductId = result.invalidProductIDs.first {
                                print("Invalid product identifier: \(invalidProductId)")
                            }
                            else {
                                print("Error: \(String(describing: result.error))")
                            }
                        }
                    }
                    
                default:
                    next(action)
                }
            }
        }
    }
}
