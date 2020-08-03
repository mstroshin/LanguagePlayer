typealias ID = Int

struct AppState: FluxState, Equatable, Codable {
    var videos = VideosListState()
}

struct VideosListState: FluxState, Equatable, Codable {
    var videos = [VideoState]()
}
