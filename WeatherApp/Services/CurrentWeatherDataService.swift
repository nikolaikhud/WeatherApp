//
//  CurrentWeatherDataService.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/21/24.
//

import Foundation
import Combine

protocol CurrentWeatherDataServiceProtocol {
    var currentWeather: CurrentWeatherAPI? { get }
    var currentWeatherPublisher: Published<CurrentWeatherAPI?>.Publisher { get }
    
    func fetchWeather(lat: Double, lon: Double)
    
    func fetchWeatherPublisher(lat: Double, lon: Double) -> AnyPublisher<CurrentWeatherAPI, Error>
    
    func fetchWeather(weatherPublisher: AnyPublisher<(weather: CurrentWeatherAPI, search: Location), any Error>, completion: @escaping (CurrentWeatherAPI, Location) -> ())
}

class CurrentWeatherDataService: CurrentWeatherDataServiceProtocol {
    @Published var currentWeather: CurrentWeatherAPI?
    private var cancellables = Set<AnyCancellable>()
    let viewState = SharedViewState.shared
    
    var currentWeatherPublisher: Published<CurrentWeatherAPI?>.Publisher { $currentWeather }
    
    func fetchWeather(lat: Double, lon: Double) {
        
        viewState.state = .loading
        
        let url = NetworkingUtilities.getURL(endpoint: .weather, lat: lat, lon: lon, units: .imperial, appid: Constants.APIKey)
        
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map { $0.data }
            .decode(type: CurrentWeatherAPI.self, decoder: JSONDecoder())
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.viewState.state = .error(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] weather in
                self?.currentWeather = weather
                self?.viewState.dismissLoadingWithAsync()
            }
            .store(in: &cancellables)
    }
}

extension CurrentWeatherDataService {
    func fetchWeatherPublisher(lat: Double, lon: Double) -> AnyPublisher<CurrentWeatherAPI, Error> {
        let url = NetworkingUtilities.getURL(endpoint: .weather, lat: lat, lon: lon, units: .imperial, appid: Constants.APIKey)
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: CurrentWeatherAPI.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchWeather(weatherPublisher: AnyPublisher<(weather: CurrentWeatherAPI, search: Location), any Error>, completion: @escaping (CurrentWeatherAPI, Location) -> ()) {
        weatherPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.viewState.state = .error(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] (weather, search) in
                completion(weather, search)
                self?.viewState.state = .idle
            }
            .store(in: &cancellables)
    }
}
