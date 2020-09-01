import ReSwift

func purchasingReducer(action: PurchasingActions, state: PurchasingState) -> PurchasingState {
    var state = state
    
    switch action {
    case let action as SaveProductsInfo:
        state.products = action.products.map {
            StoreProduct(
                localizedTitle: $0.localizedTitle,
                localizedDescription: $0.localizedDescription,
                localizedPrice: $0.localizedPrice ?? ""
            )
        }
        
    default:
        break
    }
    
    return state
}
