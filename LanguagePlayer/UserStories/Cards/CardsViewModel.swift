import Foundation
import RealmSwift
import RxSwift

class CardsViewModel {
    private let realm = try! Realm()
    private var translationResultChangeToken: NotificationToken?
    
    let translations = BehaviorSubject<[TranslationEntity]>(value: [])
    
    init() {
        
    }
    
    func viewDidLoad() {
        translationResultChangeToken = realm.objects(TranslationEntity.self).observe { [weak self] change in
            switch change {
            case .initial(let translationEntities):
                self?.translations.onNext(Array(translationEntities.filter { $0.isAddedToDictionary }))
            case .update(let translationEntities, _, _, _):
                self?.translations.onNext(Array(translationEntities.filter { $0.isAddedToDictionary }))
            case .error(let error):
                self?.translations.onError(error)
            }
        }
    }
    
    func removeTranslation(index: Int) {
        let translation = try! translations.value()[index]
        
        try! realm.write {
            realm.delete(translation)
        }
    }
    
}
