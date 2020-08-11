import ReSwift
import Foundation

typealias ID = String

struct AppState: StateType, Codable {
    var videos = [VideoState]()
    
    //Keeps added to Dictionary words
    var translations = [TranslationState]()
    
    //Keeps every translated word
    var translationsHistory = [TranslationState]()
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
}
