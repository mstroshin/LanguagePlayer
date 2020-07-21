//
//  YandexTranslationService.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 21.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import Combine

class YandexTranslationService {
    @UserDefault("iamTokenDate", defaultValue: nil)
    private var iamTokenDate: Date?
    private var iamToken: IAMToken?
    
    private let session = URLSession(configuration: .default)
    private let oAuthToken = "AgAAAAAP9CkdAATuwbxz8FBRcEyQil310C7DMqg"
    private let folderId = "b1gr9gbigb47oq6mapcp"
            
    private func getIAMToken() -> AnyPublisher<IAMToken, Error> {
        if let iamToken = self.iamToken, let iamTokenDate = self.iamTokenDate, iamTokenDate.distance(to: Date()) < 3600 {
            return Just(iamToken)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: URL(string: "https://iam.api.cloud.yandex.net/iam/v1/tokens")!)
        request.httpMethod = "POST"
        request.addValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let bodyString = "{\"yandexPassportOauthToken\": \"\(self.oAuthToken)\"}"
        request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)
        
        return self.session.dataTaskPublisher(for: request)
//            .mapError { _ in NetworkError.accessDenied }
            .map { $0.data }
            .decode(type: IAMToken.self, decoder: JSONDecoder())
//            .mapError { _ in NetworkError.jsonParsingFailure }
            .map { //Side effect
                self.iamTokenDate = Date()
                self.iamToken = $0
                return $0
            }
            .eraseToAnyPublisher()
    }
    
    private func getTranslation(for text: String, sourceLanguage: String, targetLanguage: String, iamToken: IAMToken) -> AnyPublisher<String, Error> {
        var request = URLRequest(url: URL(string: "https://translate.api.cloud.yandex.net/translate/v2/translate")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(iamToken.iamToken)", forHTTPHeaderField: "Authorization")
        let bodyObject: [String : Any] = [
            "folder_id": self.folderId,
            "texts": [text],
            "targetLanguageCode": targetLanguage,
            "sourceLanguageCode": sourceLanguage
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        return self.session.dataTaskPublisher(for: request)
//            .mapError { _ in NetworkError.accessDenied }
            .map { $0.data }
            .decode(type: Translations.self, decoder: JSONDecoder())
//            .mapError { _ in NetworkError.jsonParsingFailure }
            .map { $0.translations.first!.text }
            .eraseToAnyPublisher()
    }
}

extension YandexTranslationService: TranslationService {
    
    func translate(text: String, sourceLanguage: String, targetLanguage: String) -> AnyPublisher<String, Error> {
        return self.getIAMToken()
            .flatMap {
                self.getTranslation(for: text, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage, iamToken: $0)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
}

//Json entities
private struct IAMToken: Decodable {
    let iamToken: String
//    let expiresAt: Date
}

private struct Translations: Decodable {
    struct TranslationText: Decodable {
        let text: String
    }
    
    let translations: [TranslationText]
}
