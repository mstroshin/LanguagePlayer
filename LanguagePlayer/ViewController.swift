//
//  ViewController.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 16.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import UIKit
import AVKit
import Combine

class ViewController: UIViewController {
    @IBOutlet var subtitlesView: SubtitlesView!
    
    var controller: PlayerController?
    var subscriber: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

//        let subtitleUrl = Bundle.main.url(forResource: "rdrSub", withExtension: "srt")!
//        let subtitlesExtractor = SubtitlesExtractorSrt(with: subtitleUrl)
////        let q = s.getSubtitle(for: 10345)
////        print(q)
//
////        let player = AVPlayer(url: localUrl)
////        player.publisher(for: \.currentItem?.curre)
////        player.curr
//
//        let localUrl = Bundle.main.url(forResource: "rdr", withExtension: "mp4")!
//        let controller = PlayerController(url: localUrl)
//        self.subscriber = controller.timeInMillisecondsPublisher.sink { time in
//            if let s = subtitlesExtractor.getSubtitle(for: time) {
//                print(s)
//            }
//        }
//        controller.play()
//
//        self.controller = controller
        
        self.subtitlesView.set(text: "This whole thing is pretty much done.")
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        let label = UILabel()
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.sizeToFit()
//
//        let subtitleUrl = Bundle.main.url(forResource: "rdrSub", withExtension: "srt")!
//        let subtitlesExtractor = SubtitlesExtractorSrt(with: subtitleUrl)
//
//        let localUrl = Bundle.main.url(forResource: "rdr", withExtension: "mp4")!
//        let controller = PlayerController(url: localUrl)
//        self.controller = controller
//        self.subscriber = controller.timeInMillisecondsPublisher.sink { time in
//            if let s = subtitlesExtractor.getSubtitle(for: time) {
//                label.text = s
//                label.sizeToFit()
//            }
//        }
//        controller.play()
//
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = controller.avPlayer
//        playerViewController.view.addSubview(label)
//
//        self.present(playerViewController, animated: true) {
//            controller.play()
//            playerViewController.view.bringSubviewToFront(label)
//        }
//    }


}

