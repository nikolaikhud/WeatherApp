//
//  ForecastWeather.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/21/24.
//

import Foundation

struct ForecastWeatherItemsAPI: Codable {
    
    let list: [ListItem]
    
    struct ListItem: Codable, Identifiable {
        let id = UUID()
        let dt: Int
        let main: WeatherMain
        let weather: [Weather]
        
        enum CodingKeys: String, CodingKey {
            case dt, main, weather
        }
        
        struct WeatherMain: Codable {
            let temp: Double
        }
        
        struct Weather: Codable {
            let icon: String
        }
    }
}

struct ForecastWeatherItemUI: Identifiable {
    let id = UUID()
    let dt: String
    let temp: String
    let iconURL: URL?
}
