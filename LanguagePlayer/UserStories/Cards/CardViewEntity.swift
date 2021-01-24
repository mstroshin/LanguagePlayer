import Foundation

struct CardViewEntity {
    let id: ID
    let source: String
    let target: String
    let videoTitle: String?
    
    init(translation: FavoriteSubtitle) {
        self.id = translation.id
        self.source = translation.first
        self.target = translation.second
        self.videoTitle = translation.owners.last?.name
    }
}
