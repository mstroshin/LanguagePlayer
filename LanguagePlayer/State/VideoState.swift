import Foundation
import DifferenceKit

struct VideoState: Equatable {
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
