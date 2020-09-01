struct PurchaseIds {
    static let monthly = "Monthly1"
    static let year = "Annual1"
    static let lifetime = "Lifetime1"
    
    static var all: Set<String> {
        [monthly, year, lifetime]
    }
}
