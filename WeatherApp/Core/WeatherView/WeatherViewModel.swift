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
    
    private let _locationManager: LocationManagerProtocol?
    private let locationsDataService: LocationDataServiceProtocol
    private let currentWeatherDataService: CurrentWeatherDataServiceProtocol
    private let forecastDataService: ForecastDataServiceProtocol
    private let recentSearchesDataService: RecentSearchesDataServiceProtocol
    
    @Published var weather: CurrentWeatherUI?
    @Published var forecast: [ForecastWeatherItemUI] = []
    @Published var cityState = "–"
    @Published var tempString: String?
    
    private lazy var locationManager: LocationManagerProtocol = {
        if let locationManager = _locationManager {
            return locationManager
        } else {
            return LocationManager()
        }
    }()
    
    init(locationManager: LocationManagerProtocol? = nil,
         locationsDataService: LocationDataServiceProtocol = LocationsDataService(),
         currentWeatherDataService: CurrentWeatherDataServiceProtocol = CurrentWeatherDataService(),
         forecastDataService: ForecastDataServiceProtocol = ForecastDataService(),
         recentSearchesDataService: RecentSearchesDataServiceProtocol = RecentSearchesDataService.shared)
    {
        self._locationManager = locationManager
        self.locationsDataService = locationsDataService
        self.currentWeatherDataService = currentWeatherDataService
        self.forecastDataService = forecastDataService
        self.recentSearchesDataService = recentSearchesDataService
        addSubscribers()
        shouldWeatherBeUpdated()
    }
    
    // MARK: - Subscribing logic
    // The ViewModel is subscribed on different Data Services to be able to listen for changes that are coming from them
    
    private func addSubscribers() {
        currentWeatherSubscriber()
        forecastSubscriber()
        locationSubscriber()
    }
    
//    private let recentSearchesDataService = RecentSearchesDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private func lastKnownLocationSubscriber() {
        locationManager.lastKnownLocationPublisher
            .filter { $0 != nil }
            .first()
            .sink { [weak self] receivedLocation in
                if let receivedLocation = receivedLocation {
                    self?.updateWeather(with: receivedLocation)
                }
            }
            .store(in: &cancellables)
    }
    
    func currentWeatherSubscriber() {
        currentWeatherDataService.currentWeatherPublisher
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
        locationsDataService.fetchedLocationPublisher
            .filter { $0 != nil }
            .sink { [weak self] receivedLocation in
                if let receivedLocation = receivedLocation {
                    self?.cityState = receivedLocation.cityState
                }
            }
            .store(in: &cancellables)
    }
    
    private func forecastSubscriber() {
        forecastDataService.forecastWeatherItemsListPublisher
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
        cityState = location.cityState

        let lat = location.lat
        let lon = location.lon
        currentWeatherDataService.fetchWeather(lat: lat, lon: lon)
        forecastDataService.fetchForecast(lat: lat, lon: lon)
    }
    
    func updateWeather(name: String, state: String, cityState: String, lat: Double, lon: Double) {
        self.cityState = cityState
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
        if let search = recentSearchesDataService.recentSearches.last {
            // Update with recent search
            updateWeather(name: search.name ?? "", state: search.state ?? "", cityState: search.cityState ?? "", lat: search.lat, lon: search.lon)
        } else {
            lastKnownLocationSubscriber()
        }
    }
}
