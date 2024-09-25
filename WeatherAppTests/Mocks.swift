//
//  Mocks.swift
//  WeatherAppTests
//
//  Created by Nikolai Khudiakov on 9/25/24.
//

import Combine
import CoreLocation
import CoreData
@testable import WeatherApp


class MockLocationManager: LocationManagerProtocol {
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var lastKnownLocationPublisher: Published<CLLocationCoordinate2D?>.Publisher { $lastKnownLocation }
    var manager: CLLocationManager

    var authorizationStatus: CLAuthorizationStatus

    init(authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse) {
        self.manager = CLLocationManager()
        self.authorizationStatus = authorizationStatus
    }
}

class MockCurrentWeatherDataService: CurrentWeatherDataServiceProtocol {
    @Published var currentWeather: CurrentWeatherAPI?
    var currentWeatherPublisher: Published<CurrentWeatherAPI?>.Publisher { $currentWeather }
    
    var fetchWeatherCalled = false
    var fetchWeatherLat: Double?
    var fetchWeatherLon: Double?

    func fetchWeather(lat: Double, lon: Double) {
        fetchWeatherCalled = true
        fetchWeatherLat = lat
        fetchWeatherLon = lon
        currentWeather = CurrentWeatherAPI(
            coord: CurrentWeatherAPI.Coord(lon: lon, lat: lat),
            weather: [CurrentWeatherAPI.Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            main: CurrentWeatherAPI.WeatherMain(temp: 25.0, feelsLike: 24.0, humidity: 53),
            visibility: 10000,
            clouds: CurrentWeatherAPI.Clouds(all: 0)
        )
    }

    func fetchWeatherPublisher(lat: Double, lon: Double) -> AnyPublisher<CurrentWeatherAPI, Error> {
        if let weather = currentWeather {
            return Just(weather)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            let weather = CurrentWeatherAPI(
                coord: CurrentWeatherAPI.Coord(lon: lon, lat: lat),
                weather: [CurrentWeatherAPI.Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
                main: CurrentWeatherAPI.WeatherMain(temp: 25.0, feelsLike: 24.0, humidity: 53),
                visibility: 10000,
                clouds: CurrentWeatherAPI.Clouds(all: 0)
            )
            return Just(weather)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func fetchWeather(weatherPublisher: AnyPublisher<(weather: CurrentWeatherAPI, search: Location), any Error>, completion: @escaping (CurrentWeatherAPI, Location) -> ()) {
        _ = weatherPublisher
            .sink(receiveCompletion: { _ in }, receiveValue: { (weather, search) in
                completion(weather, search)
            })
    }
}

class MockForecastDataService: ForecastDataServiceProtocol {
    @Published var forecastWeatherItemsList: ForecastWeatherItemsAPI?
    var forecastWeatherItemsListPublisher: Published<ForecastWeatherItemsAPI?>.Publisher { $forecastWeatherItemsList }

    var fetchForecastCalled = false
    var fetchForecastLat: Double?
    var fetchForecastLon: Double?
    
    func fetchForecast(lat: Double, lon: Double) {
        fetchForecastCalled = true
        fetchForecastLat = lat
        fetchForecastLon = lon
        let forecastItem = ForecastWeatherItemsAPI.ListItem(
            dt: Int(Date().timeIntervalSince1970),
            main: ForecastWeatherItemsAPI.ListItem.WeatherMain(temp: 26.0),
            weather: [ForecastWeatherItemsAPI.ListItem.Weather(icon: "01d")]
        )
        forecastWeatherItemsList = ForecastWeatherItemsAPI(list: [forecastItem])
    }
}

class MockLocationDataService: LocationDataServiceProtocol {
    @Published var fetchedLocations: [Location] = []
    var fetchedLocationsPublisher: Published<[Location]>.Publisher { $fetchedLocations }
    
    @Published var fetchedLocation: Location?
    var fetchedLocationPublisher: Published<Location?>.Publisher { $fetchedLocation }
    
    var locationToReturn: Location?
    
    var fetchLocationsCalled = false
    var fetchLocationsQuery: String?
    
    func fetchLocations(searchQuery: String) {
        fetchLocationsCalled = true
        fetchLocationsQuery = searchQuery
        if let location = locationToReturn {
            fetchedLocations = [location]
        } else {
            let mockLocation = Location(
                name: "Test City",
                lat: 12.34,
                lon: 56.78,
                state: "Test State"
            )
            fetchedLocations = [mockLocation]
        }
    }
    
    func fetchLocation(lat: Double, lon: Double) {
        if let location = locationToReturn {
            fetchedLocation = location
        } else {
            let mockLocation = Location(
                name: "Test City",
                lat: lat,
                lon: lon,
                state: "Test State"
            )
            fetchedLocation = mockLocation
        }
    }
}

class MockRecentSearchesDataService: RecentSearchesDataServiceProtocol {
    @Published private(set) var recentSearches: [RecentSearch] = []
    var recentSearchesPublisher: Published<[RecentSearch]>.Publisher { $recentSearches }
    private let context: NSManagedObjectContext
    
    // For testing
    var updateRecentSearchesCalled = false
    var updatedLocation: Location?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func updateRecentSearches(with search: Location) {
        updateRecentSearchesCalled = true
        updatedLocation = search
        
        let recentSearch = RecentSearch(context: context)
        recentSearch.name = search.name
        recentSearch.lat = search.lat
        recentSearch.lon = search.lon
        recentSearch.state = search.state
        do {
            try context.save()
        } catch {
            print("Failed to save recent search: \(error)")
        }
        recentSearches.append(recentSearch)
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentSearch")
        do {
            let objects = try context.fetch(fetchRequest)
            for case let object as NSManagedObject in objects {
                context.delete(object)
            }
            try context.save()
        } catch {
            print("Failed to clear recent searches: \(error)")
        }
    }
}


class TestCoreDataStack {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RecentSearchContainer")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
