//
//  TranslationService.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 21.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation

struct LanguageAPIDTO: Decodable {
    let code: String
    let name: String?
}

protocol TranslationService {
    func availableLanguageCodes(callback: @escaping (Result<[LanguageAPIDTO], Error>) -> Void)
    func translate(text: String, sourceLanguage: String, targetLanguage: String, callback: @escaping (Result<String, Error>) -> Void)
}
