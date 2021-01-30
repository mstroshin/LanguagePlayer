import Foundation
import UIKit
import RxSwift

class UploadTutorialViewController: UIViewController {
    var viewModel: UploadTutorialViewModel!
    
    @IBOutlet private var addressesStackView: UIStackView!
    @IBOutlet private var ipAddressLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var tutorialLabel: UILabel!
    @IBOutlet private var orLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var errorView: NoConnectionErrorView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction))
        localization()
        bind()
        
        addressesStackView.isHidden = true
        viewModel.input.startServer.onNext(())
    }
    
    private func localization() {
        if UIDevice.iphone {
            tutorialLabel.font = .systemFont(ofSize: 18, weight: .regular)
            orLabel.font = .systemFont(ofSize: 18, weight: .regular)
            ipAddressLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            addressLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        }
        
        tutorialLabel.text = NSLocalizedString("downloaderInstruction", comment: "")
        orLabel.text = NSLocalizedString("or", comment: "")
        title = NSLocalizedString("videoDownload", comment: "")
        
        errorView.localize(
            title: NSLocalizedString("wifiError", comment: ""),
            buttonTitle: NSLocalizedString("retry", comment: "")
        )
    }
    
    private func bind() {
        viewModel.output.addresses
            .subscribe(onNext: { [weak self] addresses in
                self?.errorView.isHidden = true
                self?.addressesStackView.isHidden = false
                
                self?.ipAddressLabel.text = addresses.ip
                
                if let bonjourAddress = addresses.bonjour {
                    self?.orLabel.isHidden = false
                    self?.addressLabel.isHidden = false
                    self?.addressLabel.text = bonjourAddress
                } else {
                    self?.orLabel.isHidden = true
                    self?.addressLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.loading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                print("is loading: \(isLoading)")
                self?.activityIndicator.isHidden = !isLoading
            })
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .drive(onNext: { [weak self] error in
                if error == .noWifi {
                    self?.addressesStackView.isHidden = true
                    self?.errorView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        errorView.buttonAction = { [weak self] in
            self?.viewModel.input.startServer.onNext(())
        }
    }
    
    @objc private func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
