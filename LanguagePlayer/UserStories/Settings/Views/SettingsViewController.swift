import UIKit
import ReSwift

class SettingsViewController: UITableViewController {
    @IBOutlet weak var premiumCell: UITableViewCell!
    @IBOutlet weak var sourceLanguageCell: UITableViewCell!
    @IBOutlet weak var targetLanguageCell: UITableViewCell!
    private var isPremium = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: {
            $0.select(SettingsViewState.init)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    private func setupViews() {
        
    }
    
    @objc func downloadLanguagesAction() {
        print("downloadLanguagesAction")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        
//        if selectedCell == self.premiumCell {
//            let vc: PurchasesViewController = PurchasesViewController.createFromMainStoryboard()
//            self.present(vc, animated: true, completion: nil)
//        }
        if selectedCell == self.sourceLanguageCell {
            let vc = LanguageSelectionViewController(isSourceLanguage: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if selectedCell == self.targetLanguageCell {
            let vc = LanguageSelectionViewController(isSourceLanguage: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Premium show/hide
        if indexPath.section == 0 && indexPath.row == 0 {
            if self.isPremium {
                return 0
            } else {
                return 80
            }
        }
        
        return tableView.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //Language section
        if section == 1 {
            let footerView = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: tableView.bounds.width,
                    height: self.tableView(tableView, heightForFooterInSection: section)
                )
            )
            let button = UIButton(type: .system)
            button.setTitle("Download offline languages (~30mb)", for: .normal)
            button.addTarget(self, action: #selector(downloadLanguagesAction), for: .touchUpInside)
            footerView.addSubview(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: footerView.bottomAnchor).isActive = true
            button.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 8).isActive = true
            
            return footerView
        }
        
        return nil
    }
    
}

extension SettingsViewController: StoreSubscriber {
    typealias State = SettingsViewState
    
    func newState(state: SettingsViewState) {
        DispatchQueue.main.async {
            self.sourceLanguageCell.detailTextLabel?.text = state.selectedSourceLanguageName
            self.targetLanguageCell.detailTextLabel?.text = state.selectedTargetLanguageName
            self.isPremium = state.isPremium
            
            self.tableView.reloadData()
        }
    }
}
