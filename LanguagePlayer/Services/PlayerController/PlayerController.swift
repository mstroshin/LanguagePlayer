import MobileVLCKit

typealias Milliseconds = Int

protocol PlayerControllerDelegate: class {
    func playerController(_ player: PlayerController, changed time: Milliseconds)
    func playerController(_ player: PlayerController, videoDuration: Milliseconds)
}

class PlayerController: NSObject {
    var videoId: ID = ""
    var currentTime: Milliseconds = 0
    var videoDuration: Milliseconds {
        if let value = self.player.media.length.value {
            return value.intValue
        }
        
        return 0
    }
    var isPlaying: Bool {
        self.player.isPlaying
    }
    weak var delegate: PlayerControllerDelegate?
    private(set) var isPlayerReady = false
    
    private let player = VLCMediaPlayer()
    
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
        
    func seek(to time: Milliseconds) {
        self.currentTime = time
        self.player.time = VLCTime(number: NSNumber(value: time))
        
        if self.isPlaying == false {
            self.delegate?.playerController(self, changed: time)
        }
    }
    
}

extension PlayerController: VLCMediaPlayerDelegate {
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        self.currentTime ?= self.player.time.value?.intValue
        self.delegate?.playerController(self, changed: self.currentTime)
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
            self.delegate?.playerController(self, videoDuration: duration)
        }
    }
    
}
