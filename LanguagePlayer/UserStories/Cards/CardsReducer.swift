import ReSwift

func cardsReducer(action: CardsActions, state: AppState) -> AppState {
    var state = state
    
    switch action {
        case let action as RemoveTranslation:
            state.translations.removeAll(where: { $0.id == action.id })
        
        default:
            break
    }
    
    return state
}
