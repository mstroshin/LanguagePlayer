import UIKit
import ReSwift

class SettingsViewController: UITableViewController {
    @IBOutlet weak var sourceLanguageCell: UITableViewCell!
    @IBOutlet weak var targetLanguageCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: {
            $0.select({ $0.settings })
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    private func setupViews() {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        if selectedCell == self.sourceLanguageCell {
            let vc = LanguageSelectionViewController(isSourceLanguage: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if selectedCell == self.targetLanguageCell {
            let vc = LanguageSelectionViewController(isSourceLanguage: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension SettingsViewController: StoreSubscriber {
    typealias State = SettingsState
    
    func newState(state: SettingsState) {
        DispatchQueue.main.async {
            self.sourceLanguageCell.detailTextLabel?.text = state.selectedSourceLanguage.name
            self.targetLanguageCell.detailTextLabel?.text = state.selectedTargetLanguage.name
        }
    }
}
