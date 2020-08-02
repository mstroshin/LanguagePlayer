typealias ID = Int

struct AppState: FluxState, Equatable, Codable {
    var videos = VideosListState()
}

struct VideosListState: FluxState, Equatable, Codable {
    var videos = [VideoState]()
    
    static func reducer(action: Action, state: VideosListState) -> VideosListState {
        var state = state
        guard let action = action as? VideosListStateAction else { return state }
        
        switch action {
        case .addVideo(let videoUrl):
            return state
        }
        
        return state
    }
}
