import UIKit
import ReSwift

class LanguageSelectionViewController: UITableViewController {
    let isSourceLanguage: Bool
    var languages = [Language]()
    var selectedIndex = 0
    
    init(isSourceLanguage: Bool, style: UITableView.Style = .insetGrouped) {
        self.isSourceLanguage = isSourceLanguage
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: {
            $0.select(LanguageSelectionViewState.init)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.textLabel?.text = self.languages[indexPath.row].name
        cell.accessoryType = indexPath.row == self.selectedIndex ? .checkmark : .none
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isSourceLanguage {
            store.dispatch(SelectSourceLanguage(language: self.languages[indexPath.row]))
        } else {
            store.dispatch(SelectTargetLanguage(language: self.languages[indexPath.row]))
        }
        store.dispatch(SaveAppState())
    }
    
}

extension LanguageSelectionViewController: StoreSubscriber {
    typealias State = LanguageSelectionViewState
    
    func newState(state: LanguageSelectionViewState) {
        DispatchQueue.main.async {
            self.languages = state.languages
            self.selectedIndex = self.languages.firstIndex(where: {
                let code = self.isSourceLanguage ? state.selectedSourceLanguageCode : state.selectedTargetLanguageCode
                return $0.code == code
            }) ?? 0
            
            self.tableView.reloadData()
        }
    }
}
