//
//  LocationsDataService.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/19/24.
//

import Foundation
import Combine

protocol LocationDataServiceProtocol {
    var fetchedLocations: [Location] { get }
    var fetchedLocationsPublisher: Published<[Location]>.Publisher { get }
    var fetchedLocation: Location? { get }
    var fetchedLocationPublisher: Published<Location?>.Publisher { get }
    
    func fetchLocations(searchQuery: String)
    
    func fetchLocation(lat: Double, lon: Double)
}

class LocationsDataService: LocationDataServiceProtocol {
    
    @Published var fetchedLocations: [Location] = []
    @Published var fetchedLocation: Location?
    private var cancellables = Set<AnyCancellable>()
    let viewState = SharedViewState.shared
    
    var fetchedLocationsPublisher: Published<[Location]>.Publisher { $fetchedLocations }
    var fetchedLocationPublisher: Published<Location?>.Publisher { $fetchedLocation }
    
    func fetchLocations(searchQuery: String) {
        
        viewState.state = .loading
        
        let resultsLimit = 5
        let url = NetworkingUtilities.getURL(endpoint: .geo, searchQuery: searchQuery, limit: resultsLimit, appid: Constants.APIKey)
        
       URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map { $0.data }
            .decode(type: [Location].self, decoder: JSONDecoder())
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.viewState.state = .error(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] locations in
                self?.fetchedLocations = locations
                self?.viewState.dismissLoadingWithAsync()
            }
            .store(in: &cancellables)
    }
    
    func fetchLocation(lat: Double, lon: Double) {
        
        viewState.state = .loading
        
        let url = NetworkingUtilities.getURL(endpoint: .reverseGeo, lat: lat, lon: lon, appid: Constants.APIKey)
        
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map { $0.data }
            .decode(type: [Location].self, decoder: JSONDecoder())
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.viewState.state = .error(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] location in
                self?.fetchedLocation = location.first
                self?.viewState.dismissLoadingWithAsync()
            }
            .store(in: &cancellables)
    }
}

