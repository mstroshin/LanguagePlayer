import Foundation
import Combine

//MARK: - State
public protocol FluxState { }

//MARK: - Action
public protocol Action { }

//MARK: - Dispatch
public typealias DispatchFunction = (Action) -> Void

//MARK: - Reducer
public typealias Reducer<FluxState> =
(_ state: FluxState, _ action: Action) -> FluxState

//MARK: - Middleware
public typealias StateSupplier = () -> FluxState?

public protocol Middleware {
    func execute(getState: StateSupplier, action: Action, dispatch: @escaping DispatchFunction)
}

//MARK: - Store
final public class Store<StoreState: FluxState>: ObservableObject {
    public var state: StoreState
    public let stateChangingNotifier: CurrentValueSubject<StoreState, Never>

    private var dispatchFunction: DispatchFunction!
    private let reducer: Reducer<StoreState>
    private var cancellableMap = [Int: AnyCancellable]()
    
    public init(reducer: @escaping Reducer<StoreState>,
                middleware: [Middleware] = [],
                state: StoreState) {
        self.reducer = reducer
        self.state = state
        self.stateChangingNotifier = CurrentValueSubject(state)
        
        var dispatchFunction = { [unowned self] action in self._dispatch(action: action) }
        middleware
            .forEach({ [unowned self] middleware in
               dispatchFunction = { next in
                { [unowned self] action in
                    middleware.execute(getState: { [weak self] in self?.state }, action: action, dispatch: next)
                }
               }(dispatchFunction)
            })
        self.dispatchFunction = dispatchFunction
    }

    public func dispatch(action: Action) {
        DispatchQueue.main.async {
            self.dispatchFunction(action)
        }
    }
    
    private func _dispatch(action: Action) {
        self.state = reducer(state, action)
        self.stateChangingNotifier.send(self.state)
    }
    
    public func subscribe<T: StoreSubscriber>(_ subscriber: T) {
        let cancellable = self.stateChangingNotifier.sink { state in
            subscriber.newState(state: state)
        }
        self.cancellableMap[subscriber.hashValue] = cancellable
    }
    
    public func unsubscribe<T: StoreSubscriber>(_ subscriber: T) {
        self.cancellableMap.removeValue(forKey: subscriber.hashValue)?.cancel()
    }
}

public protocol StoreSubscriber: Hashable {
    func newState(state: FluxState)
}
