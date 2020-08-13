//
//  VideoPlayerViewController.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 21.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import AVKit
import UIKit

class VideoPlayerViewController: UIViewController {
    @IBOutlet private var subtitlesView: SubtitlesView!
    @IBOutlet private var controlsView: ControlsView!
    private var presenter: VideoPlayerPresenter!
    private weak var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        self.setupViews()        
        super.viewDidLoad()
        
        self.presenter.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.playerLayer?.frame = CGRect(origin: .zero, size: size)
            self.view.bringSubviewToFront(self.subtitlesView)
        }) { context in
            self.subtitlesView.updatePositions()
        }
    }
    
    private func setupViews() {
        self.subtitlesView.isHidden = true
        self.subtitlesView.delegate = self
                
        self.controlsView.delegate = self.presenter
    }
    
    //MARK: - Presenter input
    func show(player: AVPlayer) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        self.view.bringSubviewToFront(self.subtitlesView)
        
        self.playerLayer = playerLayer
    }
    
    func set(durationInSeconds: TimeInterval) {
        self.controlsView.set(durationInSeconds: durationInSeconds)
    }
    
    func updateTime(_ timeInMilliseconds: TimeInterval) {
        self.controlsView.set(timeInSeconds: timeInMilliseconds / 1000)
    }
    
    func showTranslated(text: String) {
        self.subtitlesView.showTranslated(text: text)
    }
    
    func startPlaying() {
        self.controlsView.isPlaying = true
        self.subtitlesView.deselectAll()
    }
    
    func stopPlaying() {
        self.controlsView.isPlaying = false
    }
    
    func show(subtitles: String) {
        if self.subtitlesView.currentText != subtitles {
            self.subtitlesView.set(text: subtitles)
            self.subtitlesView.isHidden = false
        }
    }
    
    func hideSubtitles() {
        self.subtitlesView.isHidden = true
    }
    
    func hideTranslation() {
        self.subtitlesView.hideTranslationView()
    }
    
}

extension VideoPlayerViewController: SubtitlesViewDelegate {
    
    func startedSelectingText(in subtitlesView: SubtitlesView) {
        self.presenter.startedSelectingText()
    }
    
    func subtitleView(_ subtitlesView: SubtitlesView, didSelect text: String) {
        self.presenter.translate(text: text)
    }
    
    func subtitleView(_ subtitleView: SubtitlesView, addToDictionary source: String, target: String) {
        self.presenter.addToDictionary(source: source, target: target)
    }
    
}

//Factory
extension VideoPlayerViewController {
    
    static func factory(
        translationService: TranslationService = YandexTranslationService(),
        playerController: PlayerController,
        subtitlesExtractor: SubtitlesExtractor?
    ) -> VideoPlayerViewController {
        let view: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
        
        let presenter = VideoPlayerPresenter(
            view: view,
            translationService: translationService,
            playerController: playerController,
            subtitlesExtractor: subtitlesExtractor
        )
        view.presenter = presenter
        
        return view
    }
    
    static func factory(
        videoId: ID,
        videoUrl: URL,
        sourceSubtitleUrl: URL? = nil,
        targetSubtitleUrl: URL? = nil
    ) -> VideoPlayerViewController {
        let playerController = PlayerController(id: videoId, url: videoUrl)
        
        var subtitlesExtractor: SubtitlesExtractorSrt? = nil
        if let sourceSubtitleUrl = sourceSubtitleUrl {
            subtitlesExtractor = SubtitlesExtractorSrt(with: sourceSubtitleUrl)
        }
        
        return factory(playerController: playerController, subtitlesExtractor: subtitlesExtractor)
    }
    
}
