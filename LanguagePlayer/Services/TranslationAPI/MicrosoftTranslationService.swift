//
//  MicrosoftTranslationService.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 19.10.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import RxSwift

class MicrosoftTranslationService: TranslationService {
    private let session = URLSession(configuration: .default)
    private let key = "635c17afd99140a9a0f1ec42be0be3f9"
    private let apiVersion = "3.0"
    private let region = "westeurope"
    
    func availableLanguages() -> Observable<[LanguageAPIDTO]> {
        var url = URL(string: "https://api.cognitive.microsofttranslator.com/languages")!
        let urlParams = [
            "api-version": apiVersion,
        ]
        url = url.appendingQuery(parameters: urlParams)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue(region, forHTTPHeaderField: "Ocp-Apim-Subscription-Region")
        
        return self.session.rx.data(request: request)
            .map { $0.base64EncodedData() }
            .map({ data -> Languages in
                try JSONDecoder().decode(Languages.self, from: data)
            })
            .map(\.translation)
            .map { dict in
                dict.keys.map { LanguageAPIDTO(code: $0, name: dict[$0]!.nativeName) }
            }
    }
    
    func translate(text: String, sourceLanguage: String, targetLanguage: String) -> Observable<String> {
        var url = URL(string: "https://api.cognitive.microsofttranslator.com/translate")!
        let urlParams = [
            "api-version": apiVersion,
            "from": sourceLanguage,
            "to": targetLanguage,
        ]
        url = url.appendingQuery(parameters: urlParams)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue(region, forHTTPHeaderField: "Ocp-Apim-Subscription-Region")
        
        let bodyObject = [[
            "Text": text,
        ]]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        return self.session.rx.data(request: request)
            .map({ data -> [Translations] in
                try JSONDecoder().decode([Translations].self, from: data)
            })
            .map { $0.first!.translations.first!.text }
    }
    
    //Entities
    private struct Languages: Decodable {
        let translation: [String: Language]
    }
    
    private struct Language: Decodable {
        let nativeName: String
    }
    
    private struct Translations: Decodable {
        let translations: [Translation]
    }
    
    private struct Translation: Decodable {
        let text: String
    }
    
}
