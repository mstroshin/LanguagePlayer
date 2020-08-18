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
    private let playerController: PlayerController
    private let subtitlesExtractor: SubtitlesExtractor?
    
    private var currentSubtitle: SubtitlePart?
    private var cancellables = [AnyCancellable]()
    
    init(
        view: VideoPlayerViewController,
        playerController: PlayerController,
        subtitlesExtractor: SubtitlesExtractor?
    ) {
        self.view = view
        self.playerController = playerController
        self.subtitlesExtractor = subtitlesExtractor
    }
    
    func viewDidLoad() {
        self.view?.show(player: self.playerController.avPlayer)
        
        let cancellable = self.playerController.setupTimePublisher().sink { timeInMilliseconds in
            self.view?.updateTime(timeInMilliseconds)
            
            if let subtitle = self.subtitlesExtractor?.getSubtitle(for: timeInMilliseconds) {
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
        guard let subtitle = self.currentSubtitle else { return }
        
        self.playerController.pause()
        self.view?.stopPlaying()
        
        let text = text.replacingOccurrences(of: "\n", with: " ")
        store.dispatch(AppStateActions.Translate(
            source: text,
            videoID: self.playerController.videoId,
            fromMilliseconds: subtitle.fromTime,
            toMilliseconds: subtitle.toTime
        ))
    }
    
    func addToDictionaryPressed() {        
        store.dispatch(AppStateActions.ToogleCurrentTranslationFavorite())
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
