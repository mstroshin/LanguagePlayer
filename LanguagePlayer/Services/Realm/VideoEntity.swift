import Foundation
import RealmSwift

class VideoEntity: Object {
    @objc dynamic var id: ID = UUID().uuidString
    @objc dynamic var savedInDirectoryName: String = ""
    @objc dynamic var filePath: String = ""
    @objc dynamic var thumbneilImagePath: String = ""
    let subtitleFilePaths = List<String>()
    let audioTrackNames = List<String>()
    let favoriteCards = List<CardEntity>()
    
    override class func primaryKey() -> String? { "id" }
    
    var name: String {
        URL(fileURLWithPath: filePath).lastPathComponent
    }
}

extension VideoEntity {
    
    func toDTO() -> Video {
        Video(
            id: id,
            name: name,
            path: filePath,
            savedInDirectoryName: savedInDirectoryName,
            thumbneilImagePath: thumbneilImagePath,
            subtitlePaths: Array(subtitleFilePaths),
            audioTrackNames: Array(audioTrackNames),
            favoriteCards: favoriteCards.map { $0.toDTO() }
        )
    }
    
    static func from(dto: Video) -> VideoEntity {
        let video = VideoEntity()
        video.id = dto.id
        video.savedInDirectoryName = dto.savedInDirectoryName
        video.filePath = dto.path
        video.thumbneilImagePath = dto.thumbneilImagePath
        video.subtitleFilePaths.append(objectsIn: dto.subtitlePaths)
        video.audioTrackNames.append(objectsIn: dto.audioTrackNames)
        video.favoriteCards.append(objectsIn: dto.favoriteCards.map({ CardEntity.from(dto: $0) }))
        
        return video
    }
    
}

//class VideoViewEntity {
//    let id: ID
//    let fileName: String
//    let videoUrl: URL
//    var thumbnail: UIImage?
//
//    init(video: VideoEntity) {
//        self.id = video.id
//        self.fileName = video.fileName
//        self.videoUrl = video.videoUrl
//    }
//}
//
//extension VideoViewEntity: Differentiable {
//    var differenceIdentifier: ID {
//        id
//    }
//
//    func isContentEqual(to source: VideoViewEntity) -> Bool {
//        id == source.id
//    }
//}
