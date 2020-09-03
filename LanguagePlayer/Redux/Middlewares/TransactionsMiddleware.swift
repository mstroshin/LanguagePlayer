import ReSwift

func transactionsMiddleware(purchaseService: PurchaseService) -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case let action as Purchase:
                    next(LoadingPurchase())
                    
                    purchaseService.buyProduct(id: action.id) { result in
                        switch result {
                            case .success(let id):
                                next(PurchaseCompleted(id: id, error: nil))
                                
                            case .failure(let error):
                                print((error as NSError).localizedDescription)
                                next(PurchaseCompleted(id: action.id, error: error))
                        }
                    }
                    
                case _ as RestorePurchase:
                    purchaseService.restorePurchases { result in
                        switch result {
                            case .success(let ids):
                                print("Restored \(ids)")
                                
                            case .failure(let error):
                                print((error as NSError).localizedDescription)
                        }
                    }
                    
                case _ as RetrieveProductsInfo:
                    next(LoadingProductsInfo())
                    
                    purchaseService.requestProducts { result in
                        switch result {
                            case .success(let products):
                                print("RetrieveProductsInfo \(products)")
                                next(SaveProductsInfo(products: products))
                                
                            case .failure(let error):
                                print((error as NSError).localizedDescription)
                                next(LoadingProductsInfoError(error: error))
                        }
                    }
                    
                default:
                    next(action)
                }
            }
        }
    }
}
