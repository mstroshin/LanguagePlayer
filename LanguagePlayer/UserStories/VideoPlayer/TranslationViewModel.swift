//
//  TranslationViewModel.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 10.11.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class TranslationViewModel {
    private let realm: Realm
    private let webTranslationService: TranslationService
    private let translation = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
    let translationSubject = BehaviorSubject<TranslationEntity?>(value: nil)
    let translationLoading = PublishSubject<Bool>()
    
    init(webTranslationService: TranslationService = MicrosoftTranslationService(), video: VideoEntity) {
        let realm = try! Realm()
        self.realm = realm
        self.webTranslationService = webTranslationService
                    
        disposeBag.insert(self.translation
            .flatMapLatest({ source -> Observable<TranslationEntity> in
                if let existTranslation = realm.objects(TranslationEntity.self).filter({ $0.source == source }).last {
                    return Observable.just(existTranslation)
                }
                
                return webTranslationService.translate(text: source, sourceLanguage: "en", targetLanguage: "ru")
                    .observe(on: MainScheduler())
                    .map { target in
                        let translationEntity = TranslationEntity()
                        translationEntity.source = source
                        translationEntity.target = target
                        
                        return translationEntity
                    }
                    .do(onNext: { translationEntity in
                        try! realm.write {
                            video.translations.append(translationEntity)
                            realm.add(translationEntity)
                        }
                    })
            })
            .do(onNext: { _ in
                self.translationLoading.onNext(false)
            })
            .bind(to: self.translationSubject))
    }
    
    func translate(text: String) {
        translationLoading.onNext(true)
        translation.onNext(text)
    }
    
    func toogleDictionaryCurrentTranslation() {
        if let translation = try? translationSubject.value() {
            try! realm.write {
                translation.isAddedToDictionary = !translation.isAddedToDictionary
                translationSubject.onNext(translation)
            }
        }
    }
    
}
