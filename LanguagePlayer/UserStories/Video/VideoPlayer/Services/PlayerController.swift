import MobileVLCKit
import RxSwift

typealias Milliseconds = Int

enum PlayerStatus {
    case unready
    case ready(duration: Milliseconds)
    case pause
    case play
}

class PlayerController: NSObject {
    let status = BehaviorSubject<PlayerStatus>(value: .unready)
    let currentTime = BehaviorSubject<Milliseconds>(value: 0)
    var videoDuration: Milliseconds {
        if let value = self.player.media.length.value {
            return value.intValue
        }
        
        return 0
    }
    
    private(set) var isPlayerReady = false
    private let player = VLCMediaPlayer()
    
    
    init(videoUrl: URL) {
        super.init()
        self.player.delegate = self
        self.player.media = VLCMedia(url: videoUrl)
    }
    
    func set(viewport: UIView) {
        self.player.drawable = viewport
    }
        
    func play() {
        self.player.play()
        status.onNext(.play)
    }
    
    func pause() {
        self.player.pause()
        status.onNext(.pause)
    }
        
    func seek(to time: Milliseconds) {
        self.player.time = VLCTime(number: NSNumber(value: time))
        
        if player.isPlaying == false {
            self.currentTime.onNext(time)
        }
    }
    
}

extension PlayerController: VLCMediaPlayerDelegate {
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        if let time = self.player.time.value?.intValue {
            self.currentTime.onNext(time)
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        //Run once
        if let duration = self.player.media.length.value?.intValue, self.isPlayerReady == false {
            self.isPlayerReady = true
            
            //Disable inner subtitles
            self.player.currentVideoSubTitleIndex = -1
            
            //Choose english audio track
            let audioTrackNames = self.player.audioTrackNames as! [String]
            if audioTrackNames.count > 2 {
                if let (index, _) = audioTrackNames.enumerated().first(where: { $0.element.contains("en") }) {
                    self.player.currentAudioTrackIndex = Int32(index)
                }
            }
            
            //Send video duration
            status.onNext(.ready(duration: duration))
        }
    }
    
}
