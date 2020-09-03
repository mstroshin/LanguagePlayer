struct PurchasesViewState {
    let products: [StoreProduct]
    let isLoading: Bool
    let loadingError: Error?
    
    init(appState: AppState) {
        self.products = appState.purchasing.products
        self.isLoading = appState.purchasing.isLoading
        self.loadingError = appState.purchasing.loadingError
    }
}
