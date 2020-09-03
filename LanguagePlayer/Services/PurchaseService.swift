import Foundation
import StoreKit

typealias ProductsRequestCompletionHandler = (_ result: Result<[SKProduct], Error>) -> Void
typealias ProductBuyRequestCompletionHandler = (_ result: Result<String, Error>) -> Void
typealias ProductRestoreRequestCompletionHandler = (_ result: Result<[String], Error>) -> Void


class PurchaseService: NSObject {
    private let productIdentifiers: Set<String>
    private let paymentQueue: SKPaymentQueue
    
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var productBuyRequestCompletionHandler: ProductBuyRequestCompletionHandler?
    private var productRestoreRequestCompletionHandler: ProductRestoreRequestCompletionHandler?
    private var products = [SKProduct]()
    
    init(productIds: Set<String>) {
        self.productIdentifiers = productIds
        self.paymentQueue = SKPaymentQueue.default()
        super.init()
        
        self.paymentQueue.add(self)
    }
    
    func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        self.productsRequest?.cancel()
        self.productsRequestCompletionHandler = completionHandler

        self.productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    
    func buyProduct(id: String, completionHandler: @escaping ProductBuyRequestCompletionHandler) {
        if let product = self.products.first(where: { $0.productIdentifier == id }) {
            print("Buying \(id)...")
            
            self.productBuyRequestCompletionHandler = completionHandler
            
            let payment = SKPayment(product: product)
            self.paymentQueue.add(payment)
        } else {
            print("Product was not found. Call requestProducts(_) firstly or check productId.")
        }
    }
    
    func restorePurchases(_ completionHandler: @escaping ProductRestoreRequestCompletionHandler) {
        self.productRestoreRequestCompletionHandler = completionHandler
        self.paymentQueue.restoreCompletedTransactions()
    }
    
}

extension PurchaseService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        
        let products = response.products
        self.products = products
        self.productsRequestCompletionHandler?(.success(products))
        self.clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        
        self.products = []
        self.productsRequestCompletionHandler?(.failure(error))
        self.clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        self.productsRequest = nil
        self.productsRequestCompletionHandler = nil
    }
    
}

extension PurchaseService: SKPaymentTransactionObserver {
    
    private func clearBuyAndRestoreCompletionHandlers() {
        self.productBuyRequestCompletionHandler = nil
        self.productRestoreRequestCompletionHandler = nil
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var restoredTransaction = [SKPaymentTransaction]()
        
        for transaction in transactions {
            switch (transaction.transactionState) {
                case .purchased:
                    self.complete(transaction: transaction)
                    self.clearBuyAndRestoreCompletionHandlers()
                case .failed:
                    self.fail(transaction: transaction)
                    self.clearBuyAndRestoreCompletionHandlers()
                case .restored:
                    restoredTransaction.append(transaction)
                case .deferred:
                    break
                case .purchasing:
                    break
                @unknown default:
                    break
            }
        }
        
        if restoredTransaction.isEmpty == false {
            self.restore(transactions: restoredTransaction)
            self.clearBuyAndRestoreCompletionHandlers()
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        self.paymentQueue.finishTransaction(transaction)
        
        self.productBuyRequestCompletionHandler?(.success(transaction.payment.productIdentifier))
    }
    
    private func restore(transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
            
            print("restore... \(productIdentifier)")
            self.paymentQueue.finishTransaction(transaction)
        }
        
        let ids = transactions.compactMap { $0.original?.payment.productIdentifier }
        self.productRestoreRequestCompletionHandler?(.success(ids))
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        self.paymentQueue.finishTransaction(transaction)
        
        if let transactionError = transaction.error {
            self.productBuyRequestCompletionHandler?(.failure(transactionError))
            self.productRestoreRequestCompletionHandler?(.failure(transactionError))
        }
    }
    
}
