import AVKit
import UIKit
import RxSwift
import RxCocoa

class VideoPlayerViewController: UIViewController {
    var viewModel: VideoPlayerViewModel!

    @IBOutlet private var subtitlesView: SubtitlesView!
    @IBOutlet private var controlsView: ControlsView!
    @IBOutlet private var videoViewport: UIView!
    @IBOutlet private weak var subtitlesViewBottomConstraint: NSLayoutConstraint!
    private var isSubtitlesEnable = true
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        setupViews()
        super.viewDidLoad()
        
        self.setupBindings()
        viewModel.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    
    private func setupViews() {
        subtitlesView.delegate = viewModel
        controlsView.delegate = viewModel
        
        viewModel.set(viewport: self.videoViewport)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            subtitlesViewBottomConstraint.constant = 0
        }
    }
    
    private func setupBindings() {
        //Time label
        disposeBag.insert(viewModel.currentTime
            .map(millisecondsToTime(_:))
            .bind(to: controlsView.timeLabel.rx.text))
        
        //Slider
        disposeBag.insert(viewModel.currentTime
            .map { Float($0) }
            .subscribe(onNext: { time in
                self.controlsView.seekSlider.value = time
                self.subtitlesView.translationView(isHidden: true)
            }))
        
        //Subs visibility
        disposeBag.insert(viewModel.subVisibility
            .subscribe(onNext: { isVisible in
                self.subtitlesView.isHidden = !isVisible
                self.controlsView.subtitles(isVisible: !self.subtitlesView.isHidden)
                self.isSubtitlesEnable = isVisible
            }))
        
        //Player statuses)
        disposeBag.insert(viewModel.playerStatus
            .subscribe(onNext: { status in
                switch status {
                case .unready:
                    break
                case .ready(let duration):
                    self.controlsView.set(duration: duration)
                case .pause:
                    self.controlsView.isPlaying = false
                case .play:
                    self.subtitlesView.translationView(isHidden: true)
                    self.controlsView.isPlaying = true
                    self.subtitlesView.deselectAll()
                    
                    self.controlsView.perform(#selector(ControlsView.hideAnimated), with: nil, afterDelay: 1)
                }
            }))
        
        //Displaying subtitles
        if let subtitleObservable = viewModel.currentSubtitle {
            disposeBag.insert(Observable.combineLatest(subtitleObservable, viewModel.subVisibility)
                .subscribe(onNext: { subtitle, isVisible in
                    if let subtitle = subtitle, isVisible {
                        self.subtitlesView.isHidden = false
                        self.subtitlesView.set(text: subtitle.text)
                    } else {
                        self.subtitlesView.isHidden = true
                    }
                }))
        }
        
        disposeBag.insert(viewModel.translation
            .observeOn(MainScheduler())
            .subscribe(onNext: { translation in
                if let translation = translation {
                    self.subtitlesView.update(translation: translation)
                }
            }))
        
        disposeBag.insert(viewModel.translationLoading
            .observeOn(MainScheduler())
            .subscribe(onNext: { isLoading in
                self.subtitlesView.translationView(isHidden: false)
                self.subtitlesView.set(isTranslating: isLoading)
            }))
    }
    
    private func millisecondsToTime(_ milliseconds: Milliseconds) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        return formatter.string(from: TimeInterval(milliseconds / 1000))!
    }
    
    @IBAction func didTapOnViewport(_ sender: UITapGestureRecognizer) {
        self.controlsView.toogleVisibility()
    }
    
}
