import Foundation
import UIKit
import RxSwift

class UploadTutorialViewController: UIViewController {
    @IBOutlet private var ipAddressLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var tutorialLabel: UILabel!
    @IBOutlet private var orLabel: UILabel!
    
    private var viewModel: UploadTutorialViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = UploadTutorialViewModel()
        
        bind()
    }
    
    private func bind() {
        viewModel.output.addresses
            .subscribe(onNext: { [weak self] addresses in
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
    }
}
