import Foundation
import RealmSwift
import DifferenceKit

class VideoEntity: Object {
    @objc dynamic var id: ID = UUID().uuidString
    @objc dynamic var savedInDirectoryName: String = ""
    @objc dynamic var fileName: String = ""
    @objc dynamic var sourceSubtitleFileName: String?
    @objc dynamic var targetSubtitleFileName: String?
    let translations = List<TranslationEntity>()
    
    override class func primaryKey() -> String? { "id" }
    
    var videoUrl: URL {
        LocalDiskStore().url(for: savedInDirectoryName, fileName: fileName) ?? URL(fileURLWithPath: "")
    }
    
    var sourceSubtitleUrl: URL? {
        LocalDiskStore().url(for: savedInDirectoryName, fileName: sourceSubtitleFileName)
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
