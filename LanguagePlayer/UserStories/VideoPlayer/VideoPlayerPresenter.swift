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
    private let playerController: PlayerController
    private let subtitlesExtractor: SubtitlesExtractor
    
    private var cancellables = [AnyCancellable]()
    
    init(
        view: VideoPlayerViewController,
        translationService: TranslationService,
        playerController: PlayerController,
        subtitlesExtractor: SubtitlesExtractor
    ) {
        self.view = view
        self.translationService = translationService
        self.playerController = playerController
        self.subtitlesExtractor = subtitlesExtractor
    }
    
    func viewDidLoad() {
        self.view?.show(player: self.playerController.avPlayer)
        
        let cancellable = self.playerController.setupTimePublisher().sink { timeInMilliseconds in
            self.view?.updateTime(timeInMilliseconds)
            
            if let subtitle = self.subtitlesExtractor.getSubtitle(for: timeInMilliseconds) {
                self.view?.show(subtitles: subtitle)
            } else {
                self.view?.hideSubtitles()
            }
        }
        self.cancellables.append(cancellable)
        
        self.view?.set(durationInSeconds: self.playerController.videoDurationInSeconds)
        self.playerController.play()
        self.view?.startPlaying()
    }
    
    func startedSelectingText() {
        self.playerController.pause()
        self.view?.stopPlaying()
    }
    
    func translate(text: String) {
        self.playerController.pause()
        self.view?.stopPlaying()
        
//        let cancellable = self.translationService.translate(text: text, sourceLanguage: "en", targetLanguage: "ru")
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print(error.localizedDescription)
//                case .finished:
//                    print("finished")
//                }
//            }) { translatedText in
//                self.view?.showTranslated(text: translatedText)
//        }
//        self.cancellables.append(cancellable)
        self.view?.showTranslated(text: text)
    }
}

extension VideoPlayerPresenter: ControlsViewDelegate {
    
    func didPressClose() {
        self.playerController.pause()
        self.view?.dismiss(animated: true, completion: nil)
    }
    
    func didPressBackwardFifteen() {
        self.view?.hideTranslation()
        self.playerController.seek(timeInSeconds: self.playerController.currentTimeInSeconds - 15)
    }
    
    func didPressForwardFifteen() {
        self.view?.hideTranslation()
        self.playerController.seek(timeInSeconds: self.playerController.currentTimeInSeconds + 15)
    }
    
    func didPressPlay() {
        self.playerController.play()
        self.view?.startPlaying()
        self.view?.hideTranslation()
    }
    
    func didPressPause() {
        self.playerController.pause()
        self.view?.stopPlaying()
    }
    
    func didPressScreenTurn() {
        
    }
    
    func seekValueChangedSeekSlider(timeInSeconds: TimeInterval) {
        self.view?.hideTranslation()
        self.playerController.seek(timeInSeconds: timeInSeconds)
    }
    
}
