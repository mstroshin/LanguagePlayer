//
//  VideoPlayerViewController.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 21.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import UIKit

class VideoPlayerViewController: UIViewController {
    @IBOutlet private var subtitlesView: SubtitlesView!
    private let translationView = TranslationView.createFromXib()
    private var presenter: VideoPlayerPresenter!
    
    override func viewDidLoad() {
        self.setupViews()
        self.subtitlesView.set(text: "A pair of hucksters trying to rob each other…")
        
        super.viewDidLoad()
    }
    
    private func setupViews() {
        self.subtitlesView.delegate = self
        
        self.translationView.isHidden = true
        self.view.addSubview(self.translationView)
    }
    
    //MARK: - Presenter input
    func showTranslated(text: String) {
        self.translationView.translationLabel.text = text
        self.translationView.isHidden = false
    }
    
}

extension VideoPlayerViewController: SubtitlesViewDelegate {
    
    func subtitleView(_ subtitlesView: SubtitlesView, didSelect text: String, in rect: CGRect, in range: NSRange) {
        print("Text: \(text), rect: \(rect), range: \(range)")
        
        subtitlesView.deselectAll()
        subtitlesView.select(text: text)
        
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
        self.presenter.translate(text: text)
    }
    
}

//Factory
extension VideoPlayerViewController {
    
    static func factory(translationService: TranslationService = YandexTranslationService()) -> VideoPlayerViewController {
        let view: VideoPlayerViewController = VideoPlayerViewController.createFromMainStoryboard()
        
        let presenter = VideoPlayerPresenter(view: view, translationService: translationService)
        view.presenter = presenter
        
        return view
    }
    
}
