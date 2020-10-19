import ReSwift
import Combine

func translationMiddleware(translationService: TranslationService) -> Middleware<AppState> {
    var cancellable: AnyCancellable?
    
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case _ as GetAvailableLanguages:
                    cancellable = translationService.availableLanguages()
                        .replaceError(with: [])
                        .sink(receiveCompletion: { _ in}) { languages in
                        next(SaveAvailableLanguages(languages: languages))
                        next(SaveAppState())
                    }
                    
                case let action as Translate:
                    guard let state = getState() else { return }
                    if let translation = state.translationsHistory.first(where: { $0.source == action.source }) {
                        let data = TranslationModel(
                            source: translation.source,
                            target: translation.target,
                            videoID: translation.videoId,
                            fromTime: translation.fromTime,
                            toTime: translation.toTime
                        )
                        next(TranslationResult(data: data, error: nil))
                        return
                    }
                    
                    next(Translating())
                    
                    let text = action.source.replacingOccurrences(of: "\n", with: " ")
                    cancellable = translationService.translate(
                        text: text,
                        sourceLanguage: state.settings.selectedSourceLanguage.code,
                        targetLanguage: state.settings.selectedTargetLanguage.code
                    )
                    .sink { completion in
                        if case .failure(let error) = completion {
                            next(TranslationResult(data: nil, error: error))
                        }
                    } receiveValue: { translatedText in
                        let data = TranslationModel(
                            source: action.source,
                            target: translatedText,
                            videoID: action.videoID,
                            fromTime: action.fromTime,
                            toTime: action.toTime
                        )
                        next(TranslationResult(data: data, error: nil))
                        next(AddTranslationToHistory(data: data))
                        next(SaveAppState())
                    }
                    
                default:
                    next(action)
                }
            }
        }
    }
}
