//
//  NetworkingUtilities.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/20/24.
//

import Foundation

struct NetworkingUtilities {
    
    enum Endpoint {
        case geo
        case reverseGeo
        case weather
        case forecast
        case icon
        
        var path: String {
            switch self {
            case .geo:
                return Constants.API.geoEndpoint
            case .reverseGeo:
                return Constants.API.reverseGeoEndpoint
            case .weather:
                return Constants.API.weatherEndpoint
            case .forecast:
                return Constants.API.forecastEndpoint
            case .icon:
                return Constants.API.icon
            }
        }
    }
    
    enum Units: String {
        case imperial = "imperial"
        case metric = "metric"
    }
    
    static func getURL(endpoint: Endpoint, searchQuery: String? = nil, lat: Double? = nil, lon: Double? = nil, units: Units? = nil, cnt: Int? = nil, limit: Int? = nil, appid: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Constants.API.host
        components.path = endpoint.path
        var queryItems: [URLQueryItem] = []
        
        if let searchQuery = searchQuery {
            queryItems.append(URLQueryItem(name: "q", value: "\(searchQuery),US"))
        }
        
        if let lat = lat {
            queryItems.append(URLQueryItem(name: "lat", value: String(lat)))
        }
        
        if let lon = lon {
            queryItems.append(URLQueryItem(name: "lon", value: String(lon)))
        }
        
        if let units = units {
            queryItems.append(URLQueryItem(name: "units", value: units.rawValue))
        }
        if let cnt = cnt {
            queryItems.append(URLQueryItem(name: "cnt", value: String(cnt)))
        }
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        queryItems.append(URLQueryItem(name: "appid", value: appid))
        components.queryItems = queryItems
        
        guard let url = components.url else { fatalError("Invalid URL") }
        
        return url
    }
    
    static func getIconURL(iconCode: String) -> URL? {
        if iconCode.isEmpty { return nil }
        
        let baseURLString = "https://openweathermap.org/img/wn/"
        let iconURLString = "\(baseURLString)\(iconCode)@2x.png"
        
        guard let url = URL(string: iconURLString) else { fatalError("Invalid URL") }
        
        return url
    }
}
