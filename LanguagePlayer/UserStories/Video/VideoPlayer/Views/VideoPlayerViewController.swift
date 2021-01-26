import AVKit
import UIKit
import RxSwift
import RxCocoa

class VideoPlayerViewController: UIViewController {
    var viewModel: VideoPlayerViewModel!

    @IBOutlet private weak var subtitlesView: DoubleSubtitlesView!
    @IBOutlet private weak var controlsView: ControlsView!
    @IBOutlet private weak var videoViewport: UIView!
    @IBOutlet private weak var subtitlesViewBottomConstraint: NSLayoutConstraint!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        setupViews()
        super.viewDidLoad()
        
        setupBindings()
        viewModel.input.isPlaying.onNext(true)
    }
        
    override var prefersStatusBarHidden: Bool { true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    
    private func setupViews() {
        controlsView.delegate = self
        subtitlesView.delegate = self
        
        viewModel.set(viewport: self.videoViewport)
        
        if UIDevice.iphone {
            subtitlesViewBottomConstraint.constant = 8
        }
    }
    
    private func setupBindings() {
        //Time label
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        viewModel.output.currentTime
            .map { formatter.string(from: TimeInterval($0 / 1000))! }
            .drive(controlsView.timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        //Slider
        viewModel.output.currentTime
            .map { Float($0) }
            .drive(onNext: { [weak self] time in
                self?.controlsView.seekSlider.value = time
            })
            .disposed(by: disposeBag)
        
        //Player statuses
        viewModel.output.playerStatus
            .drive(onNext: { [weak self] status in
                switch status {
                case .unready:
                    break
                case .ready(let duration):
                    self?.controlsView.set(duration: duration)
                case .pause:
                    self?.controlsView.isPlaying = false
                case .play:
                    self?.controlsView.isPlaying = true
                    self?.controlsView.perform(#selector(ControlsView.hideAnimated), with: nil, afterDelay: 1)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.currentSubtitles
            .drive(onNext: { [weak self] subtitles in
                self?.subtitlesView.set(subtitles: subtitles)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func didTapOnViewport(_ sender: UITapGestureRecognizer) {
        controlsView.toogleVisibility()
    }
    
}

extension VideoPlayerViewController: DoubleSubtitlesViewDelegate {
    
    func didPressAddToFavorite() {
        viewModel.input.addToFavorite.onNext(())
    }
    
}

extension VideoPlayerViewController: ControlsViewDelegate {
    
    func didPressClose() {
        viewModel.input.close.onCompleted()
    }
    
    func didPressBackwardFifteen() {
        viewModel.input.backwardFifteen.onNext(())
    }
    
    func didPressForwardFifteen() {
        viewModel.input.forwardFifteen.onNext(())
    }
    
    func didPressPlay() {
        viewModel.input.isPlaying.onNext(true)
    }
    
    func didPressPause() {
        viewModel.input.isPlaying.onNext(false)
    }
    
    func didPressScreenTurn() {
        //TODO:
    }
    
    func seekValueChangedSeekSlider(time: Milliseconds) {
        viewModel.input.seek.onNext(time)
    }
    
    func didPressBackwardSub() {
        viewModel.input.backwardSub.onNext(())
    }
    
    func didPressForwardSub() {
        viewModel.input.forwardSub.onNext(())
    }
    
    func didPressToogleSubVisibility() {
        let isHidden = self.subtitlesView.isHidden
        
        subtitlesView.isHidden = !isHidden
        controlsView.subtitles(isVisible: isHidden)
    }
    
    func didPressSettings() {
        viewModel.input.openVideoSettings.onNext(())
    }
    
}

extension VideoPlayerViewController: UIPopoverPresentationControllerDelegate {
        
    // MARK: - UIPopoverPresentationControllerDelegate method
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Force popover style
        return .none
    }
    
}
