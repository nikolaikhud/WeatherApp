//
//  SearchBarView.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/19/24.
//

import SwiftUI
import UIKit

// Utilized UIKit to meet the challenge requirements. Otherwise I'd prefer to implement the Search Bar utilizing SwiftUI
struct SearchBarRepresentable: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var autoFocus: Bool = true

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            text = ""
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = CustomSearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.showsCancelButton = false
        searchBar.searchBarStyle = .minimal
        searchBar.autoFocus = autoFocus
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
             uiView.text = text
    }
}

class CustomSearchBar: UISearchBar {
    var autoFocus: Bool = true
    private var hasBecomeFirstResponder = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            if autoFocus && !hasBecomeFirstResponder {
                becomeFirstResponder()
                hasBecomeFirstResponder = true
            }
        } else {
            if hasBecomeFirstResponder {
                resignFirstResponder()
                hasBecomeFirstResponder = false
            }
        }
    }
}
