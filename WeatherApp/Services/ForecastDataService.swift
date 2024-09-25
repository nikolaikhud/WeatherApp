//
//  ForecastWeatherDataService.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/22/24.
//

import Foundation
import Combine

protocol ForecastDataServiceProtocol {
    var forecastWeatherItemsList: ForecastWeatherItemsAPI? { get }
    var forecastWeatherItemsListPublisher: Published<ForecastWeatherItemsAPI?>.Publisher { get }
    
    func fetchForecast(lat: Double, lon: Double)
}

class ForecastDataService: ForecastDataServiceProtocol {
    @Published var forecastWeatherItemsList: ForecastWeatherItemsAPI?
    var forecastSubscription: AnyCancellable?
    let viewState = SharedViewState.shared
    
    var forecastWeatherItemsListPublisher: Published<ForecastWeatherItemsAPI?>.Publisher { $forecastWeatherItemsList }
    
    func fetchForecast(lat: Double, lon: Double) {
        
        viewState.state = .loading
        
        let url = NetworkingUtilities.getURL(endpoint: .forecast, lat: lat, lon: lon, units: .imperial, cnt: 8, appid: Constants.APIKey)
        
        forecastSubscription = URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map { $0.data }
            .decode(type: ForecastWeatherItemsAPI.self, decoder: JSONDecoder())
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.viewState.state = .error(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] forecast in
                self?.forecastWeatherItemsList = forecast
                self?.viewState.dismissLoadingWithAsync()
            }
    }
}
