import Foundation

struct Video {
    let id: ID
    let name: String
    let path: String
    let savedInDirectoryName: String
    let thumbneilImagePath: String
    let subtitlePaths: [String]
    let audioTrackNames: [String]
    let favoriteCards: [Card]
}
