//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Nikolai Khudiakov on 9/18/24.
//

import XCTest
import Combine
import CoreLocation
import CoreData
@testable import WeatherApp


class WeatherViewModelTests: XCTestCase {
    
    var viewModel: WeatherViewModel!
    var mockLocationManager: MockLocationManager!
    var mockLocationsDataService: MockLocationDataService!
    var mockCurrentWeatherDataService: MockCurrentWeatherDataService!
    var mockForecastDataService: MockForecastDataService!
    var mockRecentSearchesDataService: MockRecentSearchesDataService!
    var testCoreDataStack: TestCoreDataStack!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager(authorizationStatus: .authorizedWhenInUse)
        mockLocationsDataService = MockLocationDataService()
        mockCurrentWeatherDataService = MockCurrentWeatherDataService()
        mockForecastDataService = MockForecastDataService()
        testCoreDataStack = TestCoreDataStack()
        mockRecentSearchesDataService = MockRecentSearchesDataService(context: testCoreDataStack.context)
        mockRecentSearchesDataService.clearRecentSearches()
        
        viewModel = WeatherViewModel(
            locationManager: mockLocationManager,
            locationsDataService: mockLocationsDataService,
            currentWeatherDataService: mockCurrentWeatherDataService,
            forecastDataService: mockForecastDataService,
            recentSearchesDataService: mockRecentSearchesDataService
        )
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        viewModel = nil
        mockLocationManager = nil
        mockLocationsDataService = nil
        mockCurrentWeatherDataService = nil
        mockForecastDataService = nil
        mockRecentSearchesDataService = nil
        testCoreDataStack = nil
        super.tearDown()
    }
    
    func testViewModelInitialization() {
        XCTAssertNil(viewModel.weather)
        XCTAssertTrue(viewModel.forecast.isEmpty)
        XCTAssertEqual(viewModel.cityState, "–")
        XCTAssertNil(viewModel.tempString)
    }
    
    func testWeatherUpdateOnLocationChange() {
        // Given
        let expectedLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // When
        mockLocationManager.lastKnownLocation = expectedLocation
        
        mockLocationManager.lastKnownLocationPublisher
            .sink { _ in }
            .store(in: &cancellables)
        
        // Then
        let expectation = XCTestExpectation(description: "Weather data should be fetched")
        viewModel.$weather
            .dropFirst()
            .sink { weather in
                XCTAssertNotNil(weather)
                XCTAssertEqual(weather?.lat, expectedLocation.latitude)
                XCTAssertEqual(weather?.lon, expectedLocation.longitude)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockCurrentWeatherDataService.fetchWeather(lat: expectedLocation.latitude, lon: expectedLocation.longitude)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testPublishedPropertiesUpdate() {
        // Given
        let expectation = XCTestExpectation(description: "Weather and cityState should update")
        
        viewModel.$weather
            .combineLatest(viewModel.$cityState)
            .dropFirst()
            .filter { weather, cityState in
                weather != nil && cityState != "–"
            }
            .sink { weather, cityState in
                // Then
                XCTAssertEqual(weather?.temp, "25°")
                XCTAssertEqual(cityState, "Test City, Test State")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        mockCurrentWeatherDataService.fetchWeather(lat: 37.7749, lon: -122.4194)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testForecastPropertyUpdates() {
        // Given
        let expectation = XCTestExpectation(description: "Forecast should update")
        
        viewModel.$forecast
            .dropFirst()
            .sink { forecast in
                if !forecast.isEmpty {
                    // Then
                    XCTAssertEqual(forecast.count, 2) // 1 for 'now', 1 from mock data
                    XCTAssertEqual(forecast.first?.dt, "now")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        mockCurrentWeatherDataService.fetchWeather(lat: 37.7749, lon: -122.4194)
        mockForecastDataService.fetchForecast(lat: 37.7749, lon: -122.4194)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testShouldWeatherBeUpdatedWithNoAuthorizationAndRecentSearch() {
        // Given
        mockLocationManager = MockLocationManager(authorizationStatus: .denied)
        let context = testCoreDataStack.context
        mockRecentSearchesDataService = MockRecentSearchesDataService(context: context)
        
        let recentLocation = Location(
            name: "Recent City",
            lat: 12.34,
            lon: 56.78,
            state: "Recent State"
        )
        mockRecentSearchesDataService.updateRecentSearches(with: recentLocation)
        
        mockLocationsDataService.locationToReturn = recentLocation
        
        viewModel = WeatherViewModel(
            locationManager: mockLocationManager,
            locationsDataService: mockLocationsDataService,
            currentWeatherDataService: mockCurrentWeatherDataService,
            forecastDataService: mockForecastDataService,
            recentSearchesDataService: mockRecentSearchesDataService
        )
        
        // Then
        let recentSearch = mockRecentSearchesDataService.recentSearches.last!
        XCTAssertEqual(viewModel.cityState, "\(recentSearch.name ?? ""), \(recentSearch.state ?? "")")
        
        let expectation = XCTestExpectation(description: "Weather data should be fetched with recent search coordinates")
        viewModel.$weather
            .dropFirst()
            .sink { weather in
                XCTAssertNotNil(weather)
                XCTAssertEqual(weather?.lat, recentSearch.lat)
                XCTAssertEqual(weather?.lon, recentSearch.lon)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        mockCurrentWeatherDataService.fetchWeather(lat: recentSearch.lat, lon: recentSearch.lon)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testUpdateWeatherWithLocation() {
        // Given
        let location = Location(
            name: "Test City",
            lat: 12.34,
            lon: 56.78,
            state: "Test State"
        )
        
        mockLocationsDataService.locationToReturn = location
        mockCurrentWeatherDataService.fetchWeatherCalled = false
        mockForecastDataService.fetchForecastCalled = false

        // When
        viewModel.updateWeather(with: location)

        // Then
        XCTAssertEqual(viewModel.cityState, location.cityState)
        XCTAssertTrue(mockCurrentWeatherDataService.fetchWeatherCalled)
        XCTAssertEqual(mockCurrentWeatherDataService.fetchWeatherLat, location.lat)
        XCTAssertEqual(mockCurrentWeatherDataService.fetchWeatherLon, location.lon)

        XCTAssertTrue(mockForecastDataService.fetchForecastCalled)
        XCTAssertEqual(mockForecastDataService.fetchForecastLat, location.lat)
        XCTAssertEqual(mockForecastDataService.fetchForecastLon, location.lon)
    }
    
    func testUpdateWeatherWithNameStateLatLon() {
        // Given
        let name = "Test City"
        let state = "Test State"
        let lat = 12.34
        let lon = 56.78
//        let cityState = "\(name), \(state)"
        
        let location = Location(
            name: name,
            lat: lat,
            lon: lon,
            state: state
        )
        
        mockLocationsDataService.locationToReturn = location
        mockCurrentWeatherDataService.fetchWeatherCalled = false
        mockForecastDataService.fetchForecastCalled = false

        // When
        viewModel.updateWeather(name: name, state: state, cityState: location.cityState, lat: lat, lon: lon)

        // Then
        XCTAssertEqual(viewModel.cityState, "\(name), \(state)")
        XCTAssertTrue(mockCurrentWeatherDataService.fetchWeatherCalled)
        XCTAssertEqual(mockCurrentWeatherDataService.fetchWeatherLat, lat)
        XCTAssertEqual(mockCurrentWeatherDataService.fetchWeatherLon, lon)

        XCTAssertTrue(mockForecastDataService.fetchForecastCalled)
        XCTAssertEqual(mockForecastDataService.fetchForecastLat, lat)
        XCTAssertEqual(mockForecastDataService.fetchForecastLon, lon)
    }
    
    func testUpdateWeatherWithCLLocationCoordinate2D() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 12.34, longitude: 56.78)
        
        // When
        viewModel.updateWeather(with: coordinate)
        
        // Then
        // Since this method doesn't update `cityState`, we don't check it
        XCTAssertTrue(mockCurrentWeatherDataService.fetchWeatherCalled)
        XCTAssertEqual(mockCurrentWeatherDataService.fetchWeatherLat, coordinate.latitude)
        XCTAssertEqual(mockCurrentWeatherDataService.fetchWeatherLon, coordinate.longitude)
        
        XCTAssertTrue(mockForecastDataService.fetchForecastCalled)
        XCTAssertEqual(mockForecastDataService.fetchForecastLat, coordinate.latitude)
        XCTAssertEqual(mockForecastDataService.fetchForecastLon, coordinate.longitude)
    }
    
}
