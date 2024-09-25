//
//  SearchViewTests.swift
//  WeatherAppTests
//
//  Created by Nikolai Khudiakov on 9/25/24.
//

import XCTest
import Combine
import CoreData
@testable import WeatherApp

class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    var mockLocationsDataService: MockLocationDataService!
    var mockRecentSearchesDataService: MockRecentSearchesDataService!
    var mockCurrentWeatherDataService: MockCurrentWeatherDataService!
    var testCoreDataStack: TestCoreDataStack!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockLocationsDataService = MockLocationDataService()
        testCoreDataStack = TestCoreDataStack()
        mockRecentSearchesDataService = MockRecentSearchesDataService(context: testCoreDataStack.context)
        mockRecentSearchesDataService.clearRecentSearches()
        mockCurrentWeatherDataService = MockCurrentWeatherDataService()
        
        viewModel = SearchViewModel(
            locationsDataService: mockLocationsDataService,
            recentSearchesDataService: mockRecentSearchesDataService,
            currentWeatherDataService: mockCurrentWeatherDataService,
            debounceTime: 0
        )
    }
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        viewModel = nil
        mockLocationsDataService = nil
        mockRecentSearchesDataService = nil
        mockCurrentWeatherDataService = nil
        testCoreDataStack = nil
        super.tearDown()
    }
    
    func testSearchTextUpdatesFetchLocations() {
        // Given
        let formattedText = TypeConvertation.formatCityName("San")
        let expectation = XCTestExpectation(description: "fetchLocations should be called")

        // When
        viewModel.searchText = "San"

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockLocationsDataService.fetchLocationsCalled)
            XCTAssertEqual(self.mockLocationsDataService.fetchLocationsQuery, formattedText)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLocationsUpdatedWhenFetchedLocationsPublished() {
        // Given
        let expectedLocations = [
            Location(name: "City A", lat: 10.0, lon: 20.0, state: "State A"),
            Location(name: "City B", lat: 30.0, lon: 40.0, state: "State B")
        ]
        let expectation = XCTestExpectation(description: "ViewModel.locations should be updated")
        
        // Subscribe to viewModel.locations
        viewModel.$locations
            .dropFirst()
            .sink { locations in
                XCTAssertEqual(locations, expectedLocations)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        mockLocationsDataService.fetchedLocations = expectedLocations
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateRecentSearchesCallsDataService() {
        // Given
        let location = Location(name: "Test City", lat: 12.34, lon: 56.78, state: "Test State")
        
        // When
        viewModel.updateRecentSearches(with: location)
        
        // Then
        XCTAssertTrue(mockRecentSearchesDataService.updateRecentSearchesCalled)
        
        XCTAssertEqual(mockRecentSearchesDataService.updatedLocation?.name, location.name)
        XCTAssertEqual(mockRecentSearchesDataService.updatedLocation?.lat, location.lat)
        XCTAssertEqual(mockRecentSearchesDataService.updatedLocation?.lon, location.lon)
        XCTAssertEqual(mockRecentSearchesDataService.updatedLocation?.state, location.state)
    }}
