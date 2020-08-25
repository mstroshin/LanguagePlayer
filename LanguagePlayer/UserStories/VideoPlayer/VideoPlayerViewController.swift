import AVKit
import UIKit
import ReSwift
import Combine

class VideoPlayerViewController: UIViewController {
    @IBOutlet private var subtitlesView: SubtitlesView!
    @IBOutlet private var controlsView: ControlsView!
    @IBOutlet private var videoViewport: UIView!
    
    let playerController = PlayerController()
    var subtitlesExtractor: SubtitlesExtractor!
    
    private var currentSubtitle: SubtitlePart?
    private var cancellables = [AnyCancellable]()
    private weak var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        self.setupViews()        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: { $0.select(VideoPlayerViewState.init).skipRepeats() })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.dispatch(NavigationActions.NavigationCompleted(currentScreen: .player))
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
    
    override var shouldAutorotate: Bool {
        true
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
        self.controlsView.delegate = self
        
        self.playerController.delegate = self
        self.playerController.set(viewport: self.videoViewport)
    }
    
    func set(duration: Milliseconds) {
        self.controlsView.set(duration: duration)
    }
    
    func updateTime(_ time: Milliseconds) {
        self.controlsView.set(time: time)
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
        self.playerController.pause()
        self.stopPlaying()
    }
    
    func subtitleView(_ subtitlesView: SubtitlesView, didSelect text: String) {
        guard let subtitle = self.currentSubtitle else { return }
        
        self.playerController.pause()
        self.stopPlaying()
        
        let text = text.replacingOccurrences(of: "\n", with: " ")
        store.dispatch(AppStateActions.Translate(
            source: text,
            videoID: self.playerController.videoId,
            fromTime: subtitle.fromTime,
            toTime: subtitle.toTime
        ))
    }
    
    func addToDictionaryPressed() {
        store.dispatch(AppStateActions.ToogleCurrentTranslationFavorite())
        store.dispatch(AppStateActions.SaveAppState())
    }
    
}

extension VideoPlayerViewController: ControlsViewDelegate {
    
    func didPressClose() {
        self.playerController.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    func didPressBackwardFifteen() {
        self.hideTranslation()
        self.playerController.seek(to: self.playerController.currentTime - 15 * 1000)
    }
    
    func didPressForwardFifteen() {
        self.hideTranslation()
        self.playerController.seek(to: self.playerController.currentTime + 15 * 1000)
    }
    
    func didPressPlay() {
        self.playerController.play()
        self.startPlaying()
        self.hideTranslation()
    }
    
    func didPressPause() {
        self.playerController.pause()
        self.stopPlaying()
    }
    
    //TODO
    func didPressScreenTurn() {
        
    }
    
    func seekValueChangedSeekSlider(time: Milliseconds) {
        self.hideTranslation()
        self.playerController.seek(to: time)
    }
    
    func didPressBackwardSub() {
        if let subtitle = self.subtitlesExtractor?.getPreviousSubtitle(current: self.playerController.currentTime) {
            self.currentSubtitle = subtitle
            self.show(subtitles: "\(subtitle.number) " + subtitle.text)
            self.playerController.seek(to: subtitle.fromTime)
        }
    }
    
    func didPressForwardSub() {
        if let subtitle = self.subtitlesExtractor?.getNextSubtitle(current: self.playerController.currentTime) {
            self.currentSubtitle = subtitle
            self.show(subtitles: subtitle.text)
            self.playerController.seek(to: subtitle.fromTime)
        }
    }
    
}

extension VideoPlayerViewController: PlayerControllerDelegate {
    
    func playerController(_ player: PlayerController, changed time: Milliseconds) {
        self.updateTime(time)
        
        if let subtitle = self.subtitlesExtractor?.getSubtitle(for: time) {
            if self.currentSubtitle?.number != subtitle.number {
                self.currentSubtitle = subtitle
                self.show(subtitles: subtitle.text)
            }
        } else {
            self.currentSubtitle = nil
            self.hideSubtitles()
        }
    }
    
    func playerController(_ player: PlayerController, videoDuration: Milliseconds) {
        self.set(duration: videoDuration)
    }
    
}

extension VideoPlayerViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = VideoPlayerViewState
    
    func newState(state: VideoPlayerViewState) {
        if let translation = state.tranlsation {
            self.subtitlesView.showTranslated(translation)
        }
        
        if let navigationData = state.navigationData {
            self.playerController.set(videoUrl: navigationData.videoUrl)
            self.playerController.videoId = navigationData.videoId
            
            if let sourceSubtitleUrl = navigationData.sourceSubtitleUrl {
                self.subtitlesExtractor = SubtitlesExtractorSrt(with: sourceSubtitleUrl)
            }
            
            self.playerController.play()
            self.startPlaying()
            
            self.playerController.seek(to: navigationData.fromTime)
        }
    }
}
