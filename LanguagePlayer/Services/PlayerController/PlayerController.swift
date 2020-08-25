//
//  PlayerController.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 16.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import AVKit
import Combine
import MobileVLCKit

class PlayerController: NSObject {
    var videoId: ID = ""
    var currentTimeInMilliseconds: TimeInterval {
        if let value = self.player.time.value {
            return value.doubleValue
        }
        
        return 0
    }
    var currentTimeInSeconds: TimeInterval {
        self.currentTimeInMilliseconds / 1000
    }
    var videoDurationInSeconds: TimeInterval {
        if let value = self.player.media.length.value {
            return value.doubleValue / 1000
        }
        
        return 0
    }
    
    let player = VLCMediaPlayer()
    let timeInMillisecondsPublisher = PassthroughSubject<TimeInterval, Never>()
    
    override init() {
        super.init()
        self.player.delegate = self
    }
    
    func set(viewport: UIView) {
        self.player.drawable = viewport
    }
    
    func set(videoUrl: URL) {
        self.player.media = VLCMedia(url: videoUrl)
    }
        
    func play() {
        self.player.play()
    }
    
    func pause() {
        self.player.pause()
    }
    
    func seek(timeInSeconds: TimeInterval) {
//        self.avPlayer.seek(to: CMTime(seconds: timeInSeconds, preferredTimescale: CMTimeScale(1)))
    }
    
    func seek(timeInMilliseconds: TimeInterval) {
        self.player.fastForward(atRate: Float(timeInMilliseconds))
    }
    
}

extension PlayerController: VLCMediaPlayerDelegate {
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
//        self.timeInMillisecondsPublisher.send(self.currentTimeInMilliseconds)
    }
    
}
