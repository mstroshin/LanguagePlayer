//
//  VideoPlayerPresenter.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 22.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import Combine

class VideoPlayerPresenter {
    private weak var view: VideoPlayerViewController?
    private let translationService: TranslationService
    private var cancellables = [AnyCancellable]()
    
    init(
        view: VideoPlayerViewController,
        translationService: TranslationService
    ) {
        self.view = view
        self.translationService = translationService
    }
    
    func translate(text: String) {
        let cancellable = self.translationService.translate(text: text, sourceLanguage: "en", targetLanguage: "ru")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("finished")
                }
            }) { translatedText in
                self.view?.showTranslated(text: translatedText)
        }
        self.cancellables.append(cancellable)
    }
}
