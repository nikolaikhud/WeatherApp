//
//  SearchView.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/19/24.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack {
                dismissButton
                SearchBarRepresentable(text: $viewModel.searchText, placeholder: "Enter the full city name", autoFocus: true)
                
                if viewModel.searchText.isEmpty {
                    recentSearches
                } else {
                    serachResults
                }
            }
            .padding(.horizontal, 34)
            if coordinator.globalViewState.isLoading {
                LoadingView()
            }
        }
        .alert(isPresented: .constant(coordinator.globalViewState.error != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(coordinator.globalViewState.error ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    coordinator.globalViewState = .idle
                }
            )
        }
    }
}

extension SearchView {
    private var dismissButton: some View {
        Group {
            HStack {
                Spacer()
                Button(action: {
                    coordinator.hideSearchView()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20,height: 20)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.accent, Color(UIColor.systemGray3))
                }
            }
        }
    }
    
    private var recentSearches: some View {
        VStack {
            Text("Recent Searches")
                .foregroundStyle(.accent)
                .font(.title)
            ScrollView {
                ForEach(viewModel.recentSearchesCurrentWeather) { weather in
                    Button {
                        coordinator.updateWeather(with: weather)
                        coordinator.hideSearchView()
                    } label: {
                        HStack {
                            Text(String(weather.name))
                                .font(.system(size: 24))
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(weather.temp)")
                                .font(.system(size: 24))
                            AsyncURLImage(url: weather.iconURL)
                                .frame(width: 45, height: 45)
                        }
                        .foregroundStyle(.accent)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
        }
    }
    
    private var serachResults: some View {
        HStack {
            VStack {
                ScrollView {
                    ForEach(viewModel.locations) { location in
                        HStack {
                            Button(action: {
                                coordinator.updateWeather(with: location)
                                coordinator.hideSearchView()
                                viewModel.updateRecentSearches(with: location)
                            }, label: {
                                Text("\(location.name), \(location.state)")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.accent)
                                    .padding(.bottom, 8)
                                Spacer()
                            })
                        }
                    }
                }
            }
            .padding(.leading, 8)
            Spacer()
        }
    }
}


#Preview {
    SearchView(viewModel: SearchViewModel())
}
