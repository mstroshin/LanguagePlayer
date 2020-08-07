import ReSwift
import Foundation

typealias ID = String

struct AppState: StateType, Codable {
    var videos = [VideoState]()
    var translations = [TranslationState]()
}

struct VideoState: Codable {
    let id: ID
    let title: String
    let savedFileName: String
}

struct TranslationState: Codable {
    let id: ID
    let videoId: ID
    let source: String
    let target: String
    let fromMilliseconds: TimeInterval
    let toMilliseconds: TimeInterval
}
