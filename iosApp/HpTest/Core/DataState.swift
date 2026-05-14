//
//  DataState.swift
//  HpTest
//
//  Created by Gabriel Ribeiro on 14/05/26.
//

import Foundation

enum DataState<T>: Equatable, CustomStringConvertible where T: Equatable {
    case initial
    case loading
    case ready(T)
    case error(String)

    var isInitial: Bool {
        if case .initial = self {
            return true
        } else {
            return false
        }
    }
    
    var isReady: Bool {
        if case .ready = self {
            return true
        } else {
            return false
        }
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        } else {
            return false
        }
    }
    
    var isFailure: Bool {
        if case .error = self {
            return true
        } else {
            return false
        }
    }
    
    var data: T? {
        if case let .ready(data) = self {
            return data
        } else {
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .initial:
            "Initial"
        case .loading:
            "Loading"
        case .ready:
            "Ready"
        case .error:
            "Error"
        }
    }
    
    static func == (lhs: DataState<T>, rhs: DataState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
            (.loading, .loading):
            return true
        case (.ready(let lValue), .ready(let rValue)):
            return lValue == rValue
        case (.error(let lError), .error(let rError)):
            return lError == rError
        default:
            return false
        }
    }
}
