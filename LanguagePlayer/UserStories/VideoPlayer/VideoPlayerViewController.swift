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
    private let translationView = TranslationView.createFromXib()
    private var presenter: VideoPlayerPresenter!
    
    override func viewDidLoad() {
        self.setupViews()        
        super.viewDidLoad()
        
        self.presenter.viewDidLoad()
    }
    
    private func setupViews() {
        self.subtitlesView.isHidden = true
        self.subtitlesView.delegate = self
        
        self.translationView.isHidden = true
        self.view.addSubview(self.translationView)
        
        self.controlsView.delegate = self.presenter
    }
    
    //MARK: - Presenter input
    func show(player: AVPlayer) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
    }
    
    func set(durationInSeconds: TimeInterval) {
        self.controlsView.set(durationInSeconds: durationInSeconds)
    }
    
    func updateTime(_ timeInMilliseconds: TimeInterval) {
        self.controlsView.set(timeInSeconds: timeInMilliseconds / 1000)
    }
    
    func showTranslated(text: String) {
        self.translationView.translationLabel.text = text
        self.translationView.isHidden = false
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
        self.translationView.isHidden = true
    }
    
}

extension VideoPlayerViewController: SubtitlesViewDelegate {
    
    func startedSelectingText(in subtitlesView: SubtitlesView) {
        self.presenter.startedSelectingText()
    }
    
    func subtitleView(_ subtitlesView: SubtitlesView, didSelect text: String, in rect: CGRect, in range: NSRange) {
        print("Text: \(text), rect: \(rect), range: \(range)")
                
        let rectInRootView = subtitlesView.convert(rect, to: self.view)
        let yOffset: CGFloat = 40
        let center = CGPoint(
            x: rectInRootView.origin.x + rectInRootView.width / 2,
            y: rectInRootView.origin.y - yOffset
        )
        self.showTranslationView(with: text, center: center)
    }
    
    private func showTranslationView(with text: String, center: CGPoint) {
         self.translationView.wordLabel.text = text
        self.translationView.center = center
        self.view.bringSubviewToFront(self.translationView)
        self.presenter.translate(text: text)
    }
    
}

//Factory
extension VideoPlayerViewController {
    
    static func factory(
        translationService: TranslationService = YandexTranslationService(),
        playerController: PlayerController,
        subtitlesExtractor: SubtitlesExtractor
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
    
}
