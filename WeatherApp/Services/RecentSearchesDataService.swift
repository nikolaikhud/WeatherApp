//
//  RecentSearchesDataService.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/22/24.
//

import Foundation
import CoreData

protocol RecentSearchesDataServiceProtocol {
    var recentSearches: [RecentSearch] { get }
    var recentSearchesPublisher: Published<[RecentSearch]>.Publisher { get }
    
    func updateRecentSearches(with search: Location)
}

class RecentSearchesDataService: RecentSearchesDataServiceProtocol {
    
    public static let shared = RecentSearchesDataService()
    
    @Published var recentSearches: [RecentSearch] = []
    var recentSearchesPublisher: Published<[RecentSearch]>.Publisher { $recentSearches }
    
    private let container: NSPersistentContainer
    private let containerName = "RecentSearchContainer"
    private let entityName = "RecentSearch"
    
    private init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading Core Data. \(error)")
            }
            self.getRecentSearches()
        }
    }
    
    func updateRecentSearches(with search: Location) {
        if let index = recentSearches.firstIndex(where: {
            $0.lat == search.lat &&
            $0.lon == search.lon &&
            $0.name == search.name &&
            $0.state == search.state &&
            $0.cityState == search.cityState
        }) {
            let existingSearch = recentSearches[index]
            delete(entity: existingSearch)
        }
        
        add(search: search)
        
        if recentSearches.count > 3 {
            if let oldestSearch = recentSearches.first {
                delete(entity: oldestSearch)
            }
        }
    }
    
    private func add(search: Location) {
        let entity = RecentSearch(context: container.viewContext)
        entity.lat = search.lat
        entity.lon = search.lon
        entity.name = search.name
        entity.state = search.state
        entity.cityState = search.cityState
        
        save()
        getRecentSearches()
    }
    
    private func delete(entity: RecentSearch) {
        container.viewContext.delete(entity)
        save()
        getRecentSearches()
    }
    
    private func getRecentSearches() {
        let request = NSFetchRequest<RecentSearch>(entityName: entityName)
        do {
            recentSearches = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Entities. \(error)")
        }
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to Core Data. \(error)")
        }
    }
}
