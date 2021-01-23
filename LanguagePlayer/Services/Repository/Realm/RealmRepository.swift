import Foundation
import RealmSwift

var defaultRealm: Realm = {
    let queue = DispatchQueue(label: "net.maksima.Realm")
    return try! Realm(configuration: .defaultConfiguration, queue: queue)
}()
