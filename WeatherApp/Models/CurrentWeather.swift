//
//  CurrentWeather.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/21/24.
//

import Foundation

struct CurrentWeatherAPI: Codable {
    let coord: Coord
    let weather: [Weather]
    let main: WeatherMain
    let visibility: Int
    let clouds: Clouds
    
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }

    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct WeatherMain: Codable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case humidity
        }
    }
    
    struct Clouds: Codable {
        let all: Int
    }
}

struct CurrentWeatherUI: Identifiable {
    var id = UUID()
    let lon: Double
    let lat: Double
    let mainDescription: String
    let description: String
    let iconURL: URL?
    let temp: String
    let feelsLike: String
    let humidity: String
    let visibility: String
    let cloudness: String
    
    init(lon: Double, lat: Double, mainDescription: String, description: String, iconURL: URL?, temp: String, feelsLike: String, humidity: String, visibility: String, cloudness: String) {
        self.lon = lon
        self.lat = lat
        self.mainDescription = mainDescription
        self.description = description
        self.iconURL = iconURL
        self.temp = temp
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.visibility = visibility
        self.cloudness = cloudness
    }
    
    init() {
        self.lon = 0
        self.lat = 0
        self.mainDescription = "–"
        self.description = "–"
        self.iconURL = nil
        self.temp = "–°"
        self.feelsLike = "–°"
        self.humidity = "–%"
        self.visibility = "– m"
        self.cloudness = "–%"
    }
}

struct RecentSearchCurrentWeather: Identifiable, Locatable {
    let id = UUID()
    let lat: Double
    let lon: Double
    let name: String
    let state: String?
    let temp: String
    let iconURL: URL?
    
    var cityState: String {
        if let state {
            return "\(name), \(state)"
        } else {
            return "\(name)"
        }
    }
}
