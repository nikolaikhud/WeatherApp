//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/20/24.
//

import Foundation
import Combine
import CoreLocation

class WeatherViewModel: ObservableObject {
    
    private var locationManager: LocationManager
    
    @Published var weather: CurrentWeatherUI?
    @Published var forecast: [ForecastWeatherItemUI] = []
    @Published var cityState = "–"
    @Published var tempString: String?
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        addSubscribers()
        shouldWeatherBeUpdated()
    }
    
    // MARK: - Subscribing logic
    // The ViewModel is subscribed on different Data Services to be able to listen for changes that are coming from them
    
    private func addSubscribers() {
        currentWeatherSubscriber()
        forecastSubscriber()
        lastKnownLocationSubscriber()
        locationSubscriber()
    }
    
    private let currentWeatherDataService = CurrentWeatherDataService()
    private let forecastDataService = ForecastWeatherDataService()
    private let locationsDataService = LocationsDataService()
    private let recentSearchesDataService = RecentSearchesDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private func lastKnownLocationSubscriber() {
        locationManager.$lastKnownLocation
            .filter { $0 != nil }
            .first()
            .sink { [weak self] receivedLocation in
                if let receivedLocation = receivedLocation {
                    self?.updateWeather(with: receivedLocation)
                }
            }
            .store(in: &cancellables)
    }
    
    private func currentWeatherSubscriber() {
        currentWeatherDataService.$currentWeather
            .filter { $0 != nil }
            .sink { [weak self] receivedWeather in
                if let receivedWeather = receivedWeather {
                    let convertedWeather = TypeConvertation.convertWeatherToUIData(APIData: receivedWeather)
                    self?.weather = convertedWeather
                    self?.locationsDataService.fetchLocation(lat: convertedWeather.lat, lon: convertedWeather.lon)
                }
            }
            .store(in: &cancellables)
    }
    
    private func locationSubscriber() {
        locationsDataService.$fetchedLocation
            .filter { $0 != nil }
            .sink { [weak self] receivedLocation in
                if let receivedLocation = receivedLocation {
                    self?.cityState = "\(receivedLocation.name), \(receivedLocation.state)"
                }
            }
            .store(in: &cancellables)
    }
    
    private func forecastSubscriber() {
        forecastDataService.$forecastWeatherItemsList
            .filter { $0 != nil }
            .sink { [weak self] receivedForecast in
                if let receivedForecast = receivedForecast {
                    guard let self = self else { return }
                    let weather = self.weather
                    let forecast = TypeConvertation.convertForecastToUIData(APIData: receivedForecast)
                    self.forecast = (self.composeForecastArray(weather: weather ?? CurrentWeatherUI(), forecast: forecast))
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Weather updating logic
    // Updating logic for the main ViewModel's property — 'weather'
    
    func updateWeather(with location: Location) {
        cityState = "\(location.name), \(location.state)"
        let lat = location.lat
        let lon = location.lon
        currentWeatherDataService.fetchWeather(lat: lat, lon: lon)
        forecastDataService.fetchForecast(lat: lat, lon: lon)
    }
    
    func updateWeather(name: String, state: String, lat: Double, lon: Double) {
        cityState = "\(name), \(state)"
        currentWeatherDataService.fetchWeather(lat: lat, lon: lon)
        forecastDataService.fetchForecast(lat: lat, lon: lon)
    }
    
    func updateWeather(with location: CLLocationCoordinate2D) {
        let lat = location.latitude
        let lon = location.longitude
        currentWeatherDataService.fetchWeather(lat: lat, lon: lon)
        forecastDataService.fetchForecast(lat: lat, lon: lon)
    }
    
    // MARK: - Other functions
    
    private func composeForecastArray(weather: CurrentWeatherUI, forecast: [ForecastWeatherItemUI]) -> [ForecastWeatherItemUI] {
        var result: [ForecastWeatherItemUI] = []
        result.append(ForecastWeatherItemUI(dt: "now", temp: weather.temp, iconURL: weather.iconURL))
        result.append(contentsOf: forecast)
        
        return result
    }
    
    private func shouldWeatherBeUpdated() {
        if locationManager.manager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.manager.authorizationStatus == .authorizedAlways
        {
            // do nothing — lastKnownLocationSubscriber will pickup the currnet user's location and the WeatherView will be updated
        } else if let search = recentSearchesDataService.recentSearches.last {
            // if there is any recent search in memory then update the WeatherView with it
            updateWeather(name: search.name ?? "", state: search.state ?? "", lat: search.lat, lon: search.lon)
        }
    }
}
