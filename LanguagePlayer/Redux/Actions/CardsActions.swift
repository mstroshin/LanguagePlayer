import ReSwift

protocol CardsActions: Action {}

struct RemoveTranslation: CardsActions {
    let id: ID
}
