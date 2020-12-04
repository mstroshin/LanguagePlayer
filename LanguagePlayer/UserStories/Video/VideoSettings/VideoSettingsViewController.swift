import UIKit
import RxSwift
import RxCocoa

class VideoSettingsViewController: UIViewController {
    var viewModel: VideoSettingsViewModel!
    
    @IBOutlet private weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private var settings = VideoSettings(audioStreamIndex: 0, firstSubIndex: 0, secondsSubIndex: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        viewModel.output.changedSettings
            .drive(onNext: { [weak self] settings in
                self?.settings = settings
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
}

extension VideoSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.output.audioTitles.count
        } else {
            return viewModel.output.subtitleTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "identifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "identifier")
        }
        if indexPath.section == 0 {
            cell?.textLabel?.text = viewModel.output.audioTitles[indexPath.row]
            cell?.accessoryType = indexPath.row == self.settings.audioStreamIndex ? .checkmark : .none
        } else if indexPath.section == 1 {
            cell?.textLabel?.text = viewModel.output.subtitleTitles[indexPath.row]
            cell?.accessoryType = indexPath.row == self.settings.firstSubIndex ? .checkmark : .none
        } else if indexPath.section == 2 {
            cell?.textLabel?.text = viewModel.output.subtitleTitles[indexPath.row]
            cell?.accessoryType = indexPath.row == self.settings.secondsSubIndex ? .checkmark : .none
        }
        
        return cell!
    }
    
}

extension VideoSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Аудио дорожка"
        } else if section == 1 {
            return "Первые субтитры"
        } else if section == 2 {
            return "Вторые субтитры"
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            viewModel.input.audioSelected.onNext(indexPath.row)
        } else if indexPath.section == 1 {
            viewModel.input.firstSubtitleSelected.onNext(indexPath.row)
        } else if indexPath.section == 2 {
            viewModel.input.secondSubtitleSelected.onNext(indexPath.row)
        }
    }
    
}
