import Foundation

struct VideoState: Codable {
    let id: ID
    let title: String
    let savedFileName: String
}

struct UploadedVideo {
    let videoTitle: String
    let videoData: Data
    let sourceSubtitleTitle: String
    let sourceSubtitleData: Data
}
