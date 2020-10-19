//
//  MicrosoftTranslationService.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 19.10.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import Combine

class MicrosoftTranslationService: TranslationService {
    private let session = URLSession(configuration: .default)
    private let key = "635c17afd99140a9a0f1ec42be0be3f9"
    private let apiVersion = "3.0"
    private let region = "westeurope"
    
    func availableLanguages() -> AnyPublisher<[LanguageAPIDTO], Error> {
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
        
        return self.session.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Languages.self, decoder: JSONDecoder())
            .map { $0.translation }
            .map { dict in
                dict.keys.map { LanguageAPIDTO(code: $0, name: dict[$0]!.nativeName) }
            }
            .eraseToAnyPublisher()
    }
    
    func translate(text: String, sourceLanguage: String, targetLanguage: String) -> AnyPublisher<String, Error> {
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
        
        return self.session.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Translations].self, decoder: JSONDecoder())
            .map { $0.first!.translations.first!.text }
            .eraseToAnyPublisher()
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
