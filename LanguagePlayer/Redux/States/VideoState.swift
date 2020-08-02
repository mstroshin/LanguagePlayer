import Foundation
import DifferenceKit

struct VideoState: FluxState, Equatable, Codable {
    let id: ID
    let title: String
    let url: URL
//    let previewImage: URL
    let sourceSubtitleUrl: URL?
    let targetSubtitleUrl: URL?
}

extension VideoState: Differentiable {
    typealias DifferenceIdentifier = Int?

    var differenceIdentifier: Int? {
        return id
    }
}
