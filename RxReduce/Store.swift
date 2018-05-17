//
//  Store.swift
//  RxReduce
//
//  Created by Thibault Wittemberg on 18-04-15.
//  Copyright © 2018 WarpFactor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// A Reducer mutates an input state into an output state according to an action
public typealias Reducer<StateType: State> = (_ state: StateType?, _ action: Action) -> StateType

/// A Middleware has not effect on the state, it us just triggered by a dispatch action
public typealias Middleware<StateType: State> = (_ state: StateType?, _ action: Action) -> Void

/// A Store holds the state, mutate the state through actions / reducers and exposes the state via a Driver
/// A Store is dedicated to a State Type
public protocol Store {

    /// A store is dedicated to the mutation/observation of this StateType
    associatedtype StateType: State

    /// The current State (UI compliant)
    var state: Driver<StateType> { get }

    /// Inits the Store with its reducers stack
    ///
    /// - Parameter reducers: the reducers to be executed by the dispatch function
	/// - Parameter middlewares: the middlewartes to be executed by the dispatch function (the will be executed in reverse order)
	init(withReducers reducers: [Reducer<StateType>], withMiddleware middlewares: [Middleware<StateType>]?)

    /// Dispatch an action through the reducers to mutate the state
    ///
    /// - Parameter action: the actual action that will go through the reducers
    func dispatch<ActionType: Action> (action: ActionType)
}

/// A default store that will handle a specific kind of State
public final class DefaultStore<StateType: State>: Store {

    let disposeBag = DisposeBag()

    private let stateSubject = BehaviorRelay<StateType?>(value: nil)
    public lazy var state: Driver<StateType> = { [unowned self] in
        return self.stateSubject
            .asDriver()
            .filter { $0 != nil }
            .map { $0! }
        }()

    let reducers: [Reducer<StateType>]
	let middlewares: [Middleware<StateType>]

    public init(withReducers reducers: [Reducer<StateType>], withMiddleware middlewares: [Middleware<StateType>]? = nil) {
        self.reducers = reducers
		if let middlewares = middlewares {
			self.middlewares = middlewares.reversed()
		} else {
			self.middlewares = [Middleware<StateType>]()
		}
    }

    public func dispatch<ActionType: Action> (action: ActionType) {
        // every received action is converted to an async action
        action
            .toAsync()
			.do(onNext: { (action) in
				self.middlewares.forEach({ (middleware) in
					middleware(self.stateSubject.value, action)
				})
			})
            .map { [unowned self] (action) -> StateType? in
                return self.reducers.reduce(self.stateSubject.value, { (currentState, reducer) -> StateType? in
                    return reducer(currentState, action)
                })
            }.subscribe(onNext: { [unowned self] (newState) in
                self.stateSubject.accept(newState)
            }).disposed(by: self.disposeBag)
    }
}
