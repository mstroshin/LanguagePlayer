//
//  GoogleMLTranslationService.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 26.10.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import Combine
import MLKitTranslate

class GoogleMLTranslationService: TranslationService {
    private let translator: Translator
    
    init(translator: Translator) {
        self.translator = translator
    }
    
    func availableLanguages() -> AnyPublisher<[LanguageAPIDTO], Error> {
        let availableLanguages = [
            LanguageAPIDTO(code: "af", name: "Afrikaans"),
            LanguageAPIDTO(code: "ar", name: "Arabic"),
            LanguageAPIDTO(code: "be", name: "Belarusian"),
            LanguageAPIDTO(code: "bg", name: "Bulgarian"),
            LanguageAPIDTO(code: "bn", name: "Bengali"),
            LanguageAPIDTO(code: "ca", name: "Catalan"),
            LanguageAPIDTO(code: "cs", name: "Czech"),
            LanguageAPIDTO(code: "cy", name: "Welsh"),
            LanguageAPIDTO(code: "da", name: "Danish"),
            LanguageAPIDTO(code: "de", name: "German"),
            LanguageAPIDTO(code: "el", name: "Greek"),
            LanguageAPIDTO(code: "en", name: "English"),
            LanguageAPIDTO(code: "eo", name: "Esperanto"),
            LanguageAPIDTO(code: "es", name: "Spanish"),
            LanguageAPIDTO(code: "et", name: "Estonian"),
            LanguageAPIDTO(code: "fa", name: "Persian"),
            LanguageAPIDTO(code: "fi", name: "Finnish"),
            LanguageAPIDTO(code: "fr", name: "French"),
            LanguageAPIDTO(code: "ga", name: "Irish"),
            LanguageAPIDTO(code: "gl", name: "Galician"),
            LanguageAPIDTO(code: "gu", name: "Gujarati"),
            LanguageAPIDTO(code: "he", name: "Hebrew"),
            LanguageAPIDTO(code: "hi", name: "Hindi"),
            LanguageAPIDTO(code: "hr", name: "Croatian"),
            LanguageAPIDTO(code: "ht", name: "Haitian"),
            LanguageAPIDTO(code: "hu", name: "Hungarian"),
            LanguageAPIDTO(code: "id", name: "Indonesian"),
            LanguageAPIDTO(code: "is", name: "Icelandic"),
            LanguageAPIDTO(code: "it", name: "Italian"),
            LanguageAPIDTO(code: "ja", name: "Japanese"),
            LanguageAPIDTO(code: "ka", name: "Georgian"),
            LanguageAPIDTO(code: "kn", name: "Kannada"),
            LanguageAPIDTO(code: "ko", name: "Korean"),
            LanguageAPIDTO(code: "lt", name: "Lithuanian"),
            LanguageAPIDTO(code: "lv", name: "Latvian"),
            LanguageAPIDTO(code: "mk", name: "Macedonian"),
            LanguageAPIDTO(code: "mr", name: "Marathi"),
            LanguageAPIDTO(code: "ms", name: "Malay"),
            LanguageAPIDTO(code: "mt", name: "Maltese"),
            LanguageAPIDTO(code: "nl", name: "Dutch"),
            LanguageAPIDTO(code: "no", name: "Norwegian"),
            LanguageAPIDTO(code: "pl", name: "Polish"),
            LanguageAPIDTO(code: "pt", name: "Portuguese"),
            LanguageAPIDTO(code: "ro", name: "Romanian"),
            LanguageAPIDTO(code: "ru", name: "Russian"),
            LanguageAPIDTO(code: "sk", name: "Slovak"),
            LanguageAPIDTO(code: "sl", name: "Slovenian"),
            LanguageAPIDTO(code: "sq", name: "Albanian"),
            LanguageAPIDTO(code: "sv", name: "Swedish"),
            LanguageAPIDTO(code: "sw", name: "Swahili"),
            LanguageAPIDTO(code: "ta", name: "Tamil"),
            LanguageAPIDTO(code: "te", name: "Telugu"),
            LanguageAPIDTO(code: "th", name: "Thai"),
            LanguageAPIDTO(code: "tr", name: "Turkish"),
            LanguageAPIDTO(code: "uk", name: "Ukrainian"),
            LanguageAPIDTO(code: "ur", name: "Urdu"),
            LanguageAPIDTO(code: "vi", name: "Vietnamese"),
            LanguageAPIDTO(code: "zh", name: "Chinese"),
        ]
        return Result.Publisher(availableLanguages).eraseToAnyPublisher()
    }
    
    func translate(text: String, sourceLanguage: String, targetLanguage: String) -> AnyPublisher<String, Error> {
        let subject = PassthroughSubject<String, Error>()
        
        translator.translate(text) { translatedText, error in
            if let translatedText = translatedText {
                subject.send(translatedText)
            }
            else if let error = error {
                subject.send(completion: .failure(error))
            } else {
                let error = NSError(domain: "Unknown error", code: 1, userInfo: nil)
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
}
