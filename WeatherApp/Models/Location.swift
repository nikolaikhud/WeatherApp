//
//  Location.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/19/24.
//

import Foundation

struct Location: Codable, Identifiable, Equatable, Locatable {
    var id: UUID = UUID()
    let name: String
    let lat: Double
    let lon: Double
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name, lat, lon, state
    }
    
    var cityState: String {
        if let state {
            return "\(name), \(state)"
        } else {
            return "\(name)"
        }
    }
}
