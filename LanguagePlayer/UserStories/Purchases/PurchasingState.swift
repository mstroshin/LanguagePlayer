struct PurchasingState: Codable {
    var isPremium = false
    var products: [StoreProduct] = []
}

struct StoreProduct: Codable {
    let id: ID
    let localizedTitle: String
    let localizedDescription: String
    let localizedPrice: String
}
