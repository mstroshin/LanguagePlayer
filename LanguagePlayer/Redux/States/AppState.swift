import ReSwift
import Foundation

typealias ID = String

struct AppState: StateType, Codable {
    var sourceLanguageCode = "en"
    var targetLanguageCode = "ru"
    
    var videos = [VideoState]()
    
    //Keeps added to Dictionary words
    var translations = [TranslationState]()
    
    //Keeps every translated word
    var translationsHistory = [TranslationState]()
    
    var currentTranslation: TranslationState?
}

struct VideoState: Codable {
    let id: ID
    let savedInDirectoryName: String
    let fileName: String
    let sourceSubtitleFileName: String?
    let targetSubtitleFileName: String?
}

struct TranslationState: Codable {
    let id: ID
    let videoId: ID
    let source: String
    let target: String
    let fromMilliseconds: TimeInterval
    let toMilliseconds: TimeInterval
    
    init(from model: TranslationModel) {
        self.id = UUID().uuidString
        self.videoId = model.videoID
        self.source = model.source
        self.target = model.target
        self.fromMilliseconds = model.fromMilliseconds
        self.toMilliseconds = model.toMilliseconds
    }
}
