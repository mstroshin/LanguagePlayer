import Foundation
import RealmSwift
import DifferenceKit

class VideoEntity: Object {
    @objc dynamic var id: ID = UUID().uuidString
    @objc dynamic var savedInDirectoryName: String = ""
    @objc dynamic var fileName: String = ""
    let favoriteSubtitles = List<FavoriteSubtitle>()
    let subtitleNames = List<String>()
    let audioStreamNames = List<String>()
    
    override class func primaryKey() -> String? { "id" }
    
    var videoUrl: URL {
        LocalDiskStore().url(for: savedInDirectoryName, fileName: fileName) ?? URL(fileURLWithPath: "")
    }
    
    func subtitleUrl(for index: Int) -> URL? {
        if index < 0 || index >= subtitleNames.count {
            return nil
        }
        
        let fileName = subtitleNames[index].addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        return LocalDiskStore().url(for: savedInDirectoryName, fileName: fileName)
    }
}

class VideoViewEntity {
    let id: ID
    let fileName: String
    let videoUrl: URL
    var thumbnail: UIImage?
    
    init(video: VideoEntity) {
        self.id = video.id
        self.fileName = video.fileName
        self.videoUrl = video.videoUrl
    }
}

extension VideoViewEntity: Differentiable {
    var differenceIdentifier: ID {
        id
    }
    
    func isContentEqual(to source: VideoViewEntity) -> Bool {
        id == source.id
    }
}
