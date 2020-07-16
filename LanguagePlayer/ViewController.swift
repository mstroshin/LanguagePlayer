//
//  ViewController.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 16.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let localUrl = Bundle.main.url(forResource: "rdrSub", withExtension: "srt")!
        let s = SubtitlesExtractorSrt(with: localUrl)
        let q = s.getSubtitle(for: 10345)
        print(q)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        let localUrl = Bundle.main.url(forResource: "rdr", withExtension: "mp4")!
//        let player = AVPlayer(url: localUrl)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//
//
//        let label = UILabel()
//        label.text = "qwesd aw asd w asiduqowa"
//        label.textColor = .white
//        label.sizeToFit()
//        playerViewController.view.addSubview(label)
//        playerViewController.view.bringSubviewToFront(label)
//
//        self.present(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }
//    }


}

