import ReSwift

func purchasingReducer(action: PurchasingActions, state: PurchasingState) -> PurchasingState {
    var state = state
    
    switch action {
    case let action as SaveProductsInfo:
        state.products = action.products.map {
            StoreProduct(
                id: $0.productIdentifier,
                localizedTitle: $0.localizedTitle,
                localizedDescription: $0.localizedDescription,
                localizedPrice: $0.localizedPrice ?? $0.price.stringValue
            )
        }
        
    default:
        break
    }
    
    return state
}
