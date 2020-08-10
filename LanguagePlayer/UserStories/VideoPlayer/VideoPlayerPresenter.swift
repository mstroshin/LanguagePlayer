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
    
    private var currentSubtitle: SubtitlePart?
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
                self.currentSubtitle = subtitle
                self.view?.show(subtitles: subtitle.text)
            } else {
                self.currentSubtitle = nil
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
        
        if let history = store.state.translationsHistory.first(where: { $0.source == text }) {
            self.view?.showTranslated(text: history.target)
        } else {
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
            
            guard let subtitle = self.currentSubtitle else { return }
            let action = AppStateActions.AddTranslationToHistory(
                source: text,
                target: text,
                videoID: self.playerController.videoId,
                fromMilliseconds: subtitle.fromTime,
                toMilliseconds: subtitle.toTime
            )
            store.dispatch(action)
            store.dispatch(AppStateActions.SaveAppState())
        }
    }
    
    func addToDictionary(source: String, target: String) {
        guard let subtitle = self.currentSubtitle else { return }
        
        let action = AppStateActions.SaveTranslationToDictionary(
            source: source,
            target: target,
            videoID: self.playerController.videoId,
            fromMilliseconds: subtitle.fromTime,
            toMilliseconds: subtitle.toTime
        )
        store.dispatch(action)
        store.dispatch(AppStateActions.SaveAppState())
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
