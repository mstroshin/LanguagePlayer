struct PurchasesViewState {
    let products: [StoreProduct]
    
    init(appState: AppState) {
        self.products = appState.purchasingState.products
    }
}
