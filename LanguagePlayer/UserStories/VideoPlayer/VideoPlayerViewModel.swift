//
//  VideoPlayerViewModel.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 09.11.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import RxSwift

class VideoPlayerViewModel {
    private weak var viewController: UIViewController?
    private let subtitlesExtractor: SubtitlesExtractor?
    private let playerController: PlayerController
    private let video: VideoEntity
    
    private let translationViewModel: TranslationViewModel
    
    //View bindins
    let currentTime: BehaviorSubject<Milliseconds>
    let playerStatus: BehaviorSubject<PlayerStatus>
    let subVisibility = BehaviorSubject<Bool>(value: true)
    let currentSubtitle: Observable<SubtitlePart?>?
    let translation: Observable<TranslationEntity?>
    let translationLoading: PublishSubject<Bool>
    
    init(vc: UIViewController, video: VideoEntity) {
        self.viewController = vc
        self.video = video
        
        var subtitlesExtractor: SubtitlesExtractor? = nil
        if let subtitleUrl = video.sourceSubtitleUrl {
            subtitlesExtractor = SubtitlesExtractorSrt(with: subtitleUrl)
        }
        self.subtitlesExtractor = subtitlesExtractor
        
        self.playerController = PlayerController(videoUrl: video.videoUrl)
        self.currentTime = self.playerController.currentTime
        self.playerStatus = self.playerController.status
        
        if let extractor = subtitlesExtractor {
            self.currentSubtitle = self.currentTime
                .map(extractor.getSubtitle(for:))
                .distinctUntilChanged({ lhs, rhs -> Bool in
                    lhs?.text == rhs?.text
                })
        } else {
            self.currentSubtitle = nil
        }
        
        self.translationViewModel = TranslationViewModel(video: video)
        self.translation = translationViewModel.translationSubject.asObservable()
        self.translationLoading = translationViewModel.translationLoading
    }
    
    func viewDidLoad() {
        playerController.play()
    }
    
    func set(viewport: UIView) {
        playerController.set(viewport: viewport)
    }
    
    func seek(milliseconds: Milliseconds) {
        playerController.seek(to: milliseconds)
    }
    
}

extension VideoPlayerViewModel: SubtitlesViewDelegate {
    
    func startedSelectingText(in subtitlesView: SubtitlesView) {
        playerController.pause()
    }
    
    func subtitleView(_ subtitlesView: SubtitlesView, didSelect text: String) {
        translationViewModel.translate(text: text)
    }
    
    func addToDictionaryPressed() {
        translationViewModel.toogleDictionaryCurrentTranslation()
    }
    
}

extension VideoPlayerViewModel: ControlsViewDelegate {
    
    func didPressClose() {
        self.playerController.pause()
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    func didPressBackwardFifteen() {
        let time = try! playerController.currentTime.value() - 15 * 1000
        playerController.seek(to: time)
    }
    
    func didPressForwardFifteen() {
        let time = try! playerController.currentTime.value() + 15 * 1000
        playerController.seek(to: time)
    }
    
    func didPressPlay() {
        self.playerController.play()
    }
    
    func didPressPause() {
        self.playerController.pause()
    }
    
    //TODO
    func didPressScreenTurn() {}
    
    func seekValueChangedSeekSlider(time: Milliseconds) {
        playerController.seek(to: time)
    }
    
    func didPressBackwardSub() {
        let time = try! playerController.currentTime.value()
        if let subtitle = subtitlesExtractor?.getPreviousSubtitle(current: time) {
            self.playerController.seek(to: subtitle.fromTime - 50)
        }
    }
    
    func didPressForwardSub() {
        let time = try! playerController.currentTime.value()
        if let subtitle = self.subtitlesExtractor?.getNextSubtitle(current: time) {
            self.playerController.seek(to: subtitle.fromTime - 50)
        }
    }
    
    func didPressToogleSubVisibility() {
        let isVisible = try! subVisibility.value()
        subVisibility.onNext(!isVisible)
    }
    
}
