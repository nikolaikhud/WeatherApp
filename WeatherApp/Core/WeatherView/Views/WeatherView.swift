//
//  ContentView.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/18/24.
//

import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()
                VStack {
                    searchButton
                        .padding(.horizontal, 34)
                    if (viewModel.weather == nil) {
                        placeholder
                    } else {
                        ScrollView {
                            VStack (spacing: 12) {
                                mainWeatherView
                                forecastView
                                additioanlDataView
                                Spacer()
                            }
                            .padding(.horizontal, 34)
                        }
                    }
                }
                if coordinator.globalViewState.isLoading {
                    LoadingView()
                }
            }
            .navigationDestination(isPresented: $coordinator.isShowingSearchView) {
                if let searchViewModel = coordinator.searchViewModel {
                    SearchView(viewModel: searchViewModel)
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
}


extension WeatherView {
    
    private var searchButton: some View {
        Button(action: {
            coordinator.showSearchView()
        }, label: {
            HStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .padding(.leading, 12)
                Text("Search by city/town name")
                    .font(.system(size: 14))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundStyle(.gray)
            .background(Color(UIColor.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        })
        .padding(.top, 28)
        .padding(.bottom, 16)
    }
    
    private var mainWeatherView: some View {
        VStack {
            Text(viewModel.cityState)
                .font(.system(size: 24))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            AsyncURLImage(url: viewModel.weather?.iconURL)
                .frame(width: 100, height: 100)
            Text(viewModel.weather?.temp ?? "")
                .font(.system(size: 40))
            Text(viewModel.weather?.description ?? "")
                .font(.system(size: 20))
        }
        .foregroundStyle(.accent)
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var forecastView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.forecast) { forecastItem in
                    VStack {
                        Text(forecastItem.dt)
                            .font(.system(size: 14))
                        AsyncURLImage(url: forecastItem.iconURL)
                            .frame(width: 45, height: 45)
                        Text(forecastItem.temp)
                            .font(.system(size: 20))
                    }
                    .foregroundStyle(.accent)
                }
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var additioanlDataView: some View {
        VStack (spacing: 12) {
            HStack (spacing: 12) {
                AdditionalParameterView(parameter: "Feels Like", value: viewModel.weather?.feelsLike ?? "")
                AdditionalParameterView(parameter: "Humidity", value: viewModel.weather?.humidity ?? "")
            }
            HStack (spacing: 12) {
                AdditionalParameterView(parameter: "Visibility", value: viewModel.weather?.visibility ?? "")
                AdditionalParameterView(parameter: "Cloudness", value: viewModel.weather?.cloudness ?? "")
            }
        }
    }
    
    private var placeholder: some View {
        Group {
            Spacer()
            Text("Start searching for a city/town to get the weather data")
                .font(.title)
                .foregroundStyle(.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 34)
            Spacer()
        }
    }
}

#Preview {
    WeatherView(viewModel: WeatherViewModel(locationManager: LocationManager()))
}
