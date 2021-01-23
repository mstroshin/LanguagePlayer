import Foundation
import UIKit
import RxSwift

class UploadTutorialViewController: UIViewController {
    var viewModel: UploadTutorialViewModel!
    
    @IBOutlet private var ipAddressLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var tutorialLabel: UILabel!
    @IBOutlet private var orLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        bind()
    }
    
    private func bind() {
        let output = viewModel.transform(input: UploadTutorialViewModel.Input())
        
        output.addresses
            .drive(onNext: { [weak self] addresses in
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
        
        output.loading
            .drive(onNext: { [weak self] isLoading in
                print("is loading: \(isLoading)")
                self?.activityIndicator.isHidden = !isLoading
            })
            .disposed(by: disposeBag)
    }
}
