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

class PlayerController {
    let timeInMillisecondsPublisher = PassthroughSubject<TimeInterval, Never>()
    
    let avPlayer: AVPlayer
    private var timeObservation: Any?
    
    init(url: URL) {
        self.avPlayer = AVPlayer(url: url)
        
        self.timeObservation = self.avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { [weak self] time in
          guard let self = self else { return }
          self.timeInMillisecondsPublisher.send(time.seconds * 1000)
        }
    }
    
    deinit {
        if let timeObservation = self.timeObservation {
            self.avPlayer.removeTimeObserver(timeObservation)
        }
    }
    
    func play() {
        self.avPlayer.play()
    }
    
    func pause() {
        self.avPlayer.pause()
    }
    
    func seek(to timeInMilliseconds: TimeInterval) {
        self.avPlayer.seek(to: CMTime(seconds: timeInMilliseconds / 1000, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
}
