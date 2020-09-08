import Foundation
import StoreKit

class DonationManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private var completion: ((Bool) -> Void)?
    private var completionCheck: ((Bool) -> Void)?
    private var product: SKProduct?
    static let shared = DonationManager()

    private func checkAvailability(_ completion: @escaping (Bool) -> Void) {
        self.completionCheck = completion
        let request = SKProductsRequest(productIdentifiers: Set<String>(arrayLiteral: "eu.deltasiege.korekushon.iap"))
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty, let product = response.products.first {
            self.product = product
            completionCheck?(true)
        } else {
            completionCheck?(true)
        }
    }

    func donateCoffee(_ completion: @escaping (Bool) -> Void) {
        self.completion = completion
        if SKPaymentQueue.canMakePayments() {
            checkAvailability { result in
                if result, let product = self.product {
                    print("sending payment request")
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(SKPayment(product: product))
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.completion?(true)
            case .failed:
                print(transaction.error?.localizedDescription ?? "")
                self.completion?(false)
            default:
                break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        true
    }
}
