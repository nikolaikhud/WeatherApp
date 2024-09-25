//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/19/24.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    
    private let locationsDataService: LocationDataServiceProtocol
    private let recentSearchesDataService: RecentSearchesDataServiceProtocol
    private let currentWeatherDataService: CurrentWeatherDataServiceProtocol
    private let debounceTime: Int
    
    @Published var locations: [Location] = []
    @Published var searchText: String = ""
    @Published var recentSearchesCurrentWeather: [RecentSearchCurrentWeather] = []
    var recentSearchesLocation: [Location] = []
    
    init(locationsDataService: LocationDataServiceProtocol = LocationsDataService(),
         recentSearchesDataService: RecentSearchesDataServiceProtocol = RecentSearchesDataService.shared,
         currentWeatherDataService: CurrentWeatherDataServiceProtocol = CurrentWeatherDataService(), debounceTime: Int = 1) {
        self.locationsDataService = locationsDataService
        self.recentSearchesDataService = recentSearchesDataService
        self.currentWeatherDataService = currentWeatherDataService
        self.debounceTime = debounceTime
        addSubscribers()
    }
    
    // MARK: - Subscribing logic
    // The ViewModel is subscribed on different Data Services to be able to listen for changes that are coming from them
    
    func addSubscribers() {
        locationsSubscriber()
        searchTextSubscriber()
        recentSearchesSubscriber()
    }
    
//    private let locationsDataService = LocationsDataService()
//    private let recentSearchesDataService = RecentSearchesDataService.shared
//    private let currentWeatherDataService = CurrentWeatherDataService()
    private var cancellables = Set<AnyCancellable>()
    
    private func locationsSubscriber() {
        locationsDataService.fetchedLocationsPublisher
            .filter { !$0.isEmpty }
            .sink { [weak self] receivedLocations in
                self?.locations = receivedLocations
            }
            .store(in: &cancellables)
    }
    
    private func searchTextSubscriber() {
        $searchText
            .filter { !$0.isEmpty }
            .removeDuplicates()
        //the debounce could be shorter, but I'm trying to save the free API calls :)
            .debounce(for: .seconds(debounceTime), scheduler: RunLoop.main)
            .sink { [weak self] receivedText in
                self?.locations = []
                if receivedText.count >= 3 {
                    let formatedReceivedText = TypeConvertation.formatCityName(receivedText)
                    self?.locationsDataService.fetchLocations(searchQuery: formatedReceivedText)
                }
            }
            .store(in: &cancellables)
    }
    
    private func recentSearchesSubscriber() {
        recentSearchesDataService.recentSearchesPublisher
            .filter { !$0.isEmpty }
            .map { recentSearches -> [Location] in
                recentSearches
                    .map {
                        return Location(name: $0.name ?? "", lat: $0.lat, lon: $0.lon, state: $0.state ?? "")
                    }
            }
            .first()
            .sink { [weak self] receivedRecentSearches in
                self?.recentSearchesLocation = receivedRecentSearches
                self?.fetchWeatherForRecentSearches()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Other functions
    
    // not the best solution. given more time I would work on something less cumbersome and something that would allow to sort the results
    private func fetchWeatherForRecentSearches() {
        guard !recentSearchesLocation.isEmpty else {
            return
        }
        
        let weatherPublishers = recentSearchesLocation.map { search in
            currentWeatherDataService.fetchWeatherPublisher(lat: search.lat, lon: search.lon)
                .map { (weather: $0, search: search) }
                .eraseToAnyPublisher()
        }
        
        for weatherPublisher in weatherPublishers {
            currentWeatherDataService.fetchWeather(weatherPublisher: weatherPublisher) { [weak self] weather, search in
                let weatherUI = TypeConvertation.convertWeatherToUIData(APIData: weather)
                let itemCurrentWeather = RecentSearchCurrentWeather(lat: search.lat, lon: search.lon, name: search.name, state: search.state, temp: weatherUI.temp, iconURL: weatherUI.iconURL)
                self?.recentSearchesCurrentWeather.append(itemCurrentWeather)
            }
        }
    }
    
    func updateRecentSearches(with location: Location) {
        recentSearchesDataService.updateRecentSearches(with: Location(name: location.name, lat: location.lat, lon: location.lon, state: location.state))
    }
}
