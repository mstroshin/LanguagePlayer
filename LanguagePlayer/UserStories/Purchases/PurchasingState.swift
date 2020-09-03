struct PurchasingState {
    var isPremium = false
    var products: [StoreProduct] = []
    
    var isLoading = false
    var loadingError: Error?
}

extension PurchasingState: Codable {
    
    enum CodingKeys: String, CodingKey {
        case isPremium
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isPremium = try container.decode(Bool.self, forKey: .isPremium)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isPremium, forKey: .isPremium)
    }
    
}

struct StoreProduct: Codable {
    let id: ID
    let localizedTitle: String
    let localizedDescription: String
    let localizedPrice: String
}
