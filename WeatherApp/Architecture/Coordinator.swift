//
//  Coordinator.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/20/24.
//

import Foundation
import Combine

class AppCoordinator: ObservableObject {
    // MARK: navigation and viewModels initialization
    @Published var isShowingSearchView = false
    
    let locationManager = LocationManager()
    var weatherViewModel: WeatherViewModel
    var searchViewModel: SearchViewModel?
    
    init() {
        let locationManager = LocationManager()
        self.weatherViewModel = WeatherViewModel(locationManager: locationManager)
        locationManager.checkLocationAuthorization()
        viewStateSubscriber()
    }
    
    func showSearchView() {
        searchViewModel = SearchViewModel()
        isShowingSearchView = true
    }
    
    func hideSearchView() {
        isShowingSearchView = false
        searchViewModel = nil
    }
    
    func updateWeather<T: Locatable>(with data: T) {
            weatherViewModel.updateWeather(name: data.name, state: data.state, lat: data.lat, lon: data.lon)
    }
    
    // MARK: shared view state
    // given more time I would avoid using one shared state (singleton) for all views
    @Published var globalViewState: ViewState = .idle
    private var cancellables = Set<AnyCancellable>()
    
    func viewStateSubscriber() {
        SharedViewState.shared.$state
            .sink { [weak self] viewState in
                self?.globalViewState = viewState
            }
            .store(in: &cancellables)
    }
}
