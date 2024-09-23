//
//  SearchBarView.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/19/24.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    searchText.isEmpty ?
                    Color(UIColor.systemGray2) : Color.accent
                )
                .frame(width: 14, height: 14)
            
            TextField("Enter the full city name", text: $searchText)
                .font(.system(size: 14))
                .foregroundColor(Color.accent)
                .disableAutocorrection(true)
                .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundColor(Color.accent)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            searchText = ""
                        }
                    ,alignment: .trailing
                )
                .focused($isFocused)
                .onAppear { isFocused = true }
        }
        .font(.headline)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
}
