//
//  Constants.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/20/24.
//

import Foundation

struct Constants {
    
    struct API {
        static let host = "api.openweathermap.org"
        static let geoEndpoint = "/geo/1.0/direct"
        static let reverseGeoEndpoint = "/geo/1.0/reverse"
        static let weatherEndpoint = "/data/2.5/weather"
        static let forecastEndpoint = "/data/2.5/forecast"
        static let icon = "/img/wn/"
    }
    
    static var APIKey: String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["API_KEY"] as? String
        else {
            print("Couldn't find key 'API_KEY' in 'Secrets.plist'.")
            return ""
        }
        return key
    }
}
