import ReSwift

func purchasingReducer(action: PurchasingActions, state: PurchasingState) -> PurchasingState {
    var state = state
    
    switch action {
    case _ as LoadingProductsInfo, is LoadingPurchase:
            state.isLoading = true
            
        case let action as SaveProductsInfo:
            state.isLoading = false
            state.products = action.products.map {
                StoreProduct(
                    id: $0.productIdentifier,
                    localizedTitle: $0.localizedTitle,
                    localizedDescription: $0.localizedDescription,
                    localizedPrice: $0.localizedPrice ?? $0.price.stringValue
                )
            }
            
        case let action as LoadingProductsInfoError:
            state.isLoading = false
            state.loadingError = action.error
        
        case let action as PurchaseCompleted:
            state.isLoading = false
            if let error = action.error {
                state.loadingError = error
            }
        
        default:
            break
    }
    
    return state
}
