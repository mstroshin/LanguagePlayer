import ReSwift

protocol VideosListActions: Action {}

struct UploadedFile {
    let fileName: String
    let temporaryDataPath: String
}

struct AddedVideo: VideosListActions {
    let videoFileName: String
    let sourceSubtitleFileName: String?
    let targetSubtitleFileName: String?
    let savedInDirectoryName: String
}

struct SaveVideo: VideosListActions {
    let video: UploadedFile
    let sourceSubtitle: UploadedFile?
    let targetSubtitle: UploadedFile?
}

struct RemoveVideo: VideosListActions {
    let id: ID
    let removeAllCards: Bool
}
