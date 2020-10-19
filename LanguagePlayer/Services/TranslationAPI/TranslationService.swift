//
//  TranslationService.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 21.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import Combine

struct LanguageAPIDTO {
    let code: String
    let name: String
}

protocol TranslationService {
    func availableLanguages() -> AnyPublisher<[LanguageAPIDTO], Error>
    func translate(text: String, sourceLanguage: String, targetLanguage: String) -> AnyPublisher<String, Error>
}
