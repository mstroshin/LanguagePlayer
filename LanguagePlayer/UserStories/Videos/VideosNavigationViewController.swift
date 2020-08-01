import Foundation
import UIKit

class VideosNavigationViewController: UITableViewController {
    var videos = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "id")

        self.navigationItem.title = "All Videos"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        if let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first, let content = try? FileManager.default.contentsOfDirectory(atPath: docPath) {
            let filteredContent = content.filter { !$0.contains("srt") }
            self.videos.append(contentsOf: filteredContent)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id")!
        cell.textLabel?.text = videos[indexPath.row]
        return cell
    }
    
}
