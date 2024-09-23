//
//  ViewState.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/22/24.
//

import Foundation

public enum ViewState: Equatable {
    
    case idle
    case loading
    case error(message: String)
    
    public var error: String? {
        get {
            switch self {
            case .error(let message):
                return message
            default:
                return nil
            }
        }
        set {
            if newValue != nil {
                self = .error(message: newValue!)
            } else {
                self = .idle
            }
        }
    }
    
    public var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}

public class SharedViewState {
    @Published var state: ViewState = .idle    
    public static let shared = SharedViewState()
    
    func dismissLoadingWithAsync() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.state = .idle
            }
        }
}
