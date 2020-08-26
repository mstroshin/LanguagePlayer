import Foundation
import UIKit
import ReSwift

class DictionaryViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var translations = [DictionaryViewState.TranslationViewState]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.router = DictionaryRouter(self, screen: .dictionary)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: { $0.select(DictionaryViewState.init) })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    private func setupViews() {
        
    }
}

extension DictionaryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.translations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DictionaryTableViewCell.identifier, for: indexPath) as? DictionaryTableViewCell else {
            fatalError("Cell must be DictionaryTableViewCell subclass")
        }
        let translation = self.translations[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        cell.configure(with: translation)
        
        return cell
    }
}

extension DictionaryViewController: DictionaryTableViewCellDelegate {
    
    func didPressPlayButton(in cell: DictionaryTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let translation = self.translations[indexPath.row]
        
        store.dispatch(NavigationActions.Navigate(
            screen: .player,
            transitionType: .present(.fullScreen),
            data: ["videoId": translation.videoId!,
                   "from": translation.fromTime,
                   "to": translation.toTime]
        ))
    }
    
}

extension DictionaryViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = DictionaryViewState
    
    func newState(state: DictionaryViewState) {
        self.tableView.diffUpdate(source: self.translations, target: state.translations) {
            self.translations = $0
        }
    }
}
