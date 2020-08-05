import ReSwift

typealias ID = Int

struct AppState: StateType, Codable {
    var videos = [VideoState]()
}
