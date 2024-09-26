//
//  TypeConvertation.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/21/24.
//

import Foundation

struct TypeConvertation {
    
    static func convertWeatherToUIData(APIData: CurrentWeatherAPI) -> CurrentWeatherUI {
        let lon = APIData.coord.lon
        let lat = APIData.coord.lat
        let mainDescription = APIData.weather.first?.main ?? ""
        let description = APIData.weather.first?.description.capitalized ?? ""
        let icon = APIData.weather.first?.icon ?? ""
        let iconURL = NetworkingUtilities.getIconURL(iconCode: icon)
        let temp = "\(Int(APIData.main.temp))°"
        let feelsLike = "\(Int(APIData.main.feelsLike))°"
        let humidity = "\(APIData.main.humidity)%"
        let visibility = String(format: "%.1f mi", Double(APIData.visibility) * 0.000621371)
        let cloudness = "\(APIData.clouds.all)%"
        
        let currenWeatherUI = CurrentWeatherUI(lon: lon, lat: lat, mainDescription: mainDescription, description: description, iconURL: iconURL, temp: temp, feelsLike: feelsLike, humidity: humidity, visibility: visibility, cloudness: cloudness)
        
        return currenWeatherUI
    }
    
    static func convertForecastToUIData(APIData: ForecastWeatherItemsAPI) -> [ForecastWeatherItemUI] {
        
        return APIData.list.map { listItem in
            let dt = convertUnixTimestampToHourPeriod(listItem.dt)
            let temp = "\(Int(listItem.main.temp))°"
            
            let icon = listItem.weather.first?.icon ?? ""
            let iconURL = NetworkingUtilities.getIconURL(iconCode: icon)
            
            return ForecastWeatherItemUI(
                dt: dt,
                temp: temp,
                iconURL: iconURL
            )
        }
    }
    
    static func convertUnixTimestampToHourPeriod(_ unixTimestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        dateFormatter.timeZone = TimeZone.current
        
        let formattedDate = dateFormatter.string(from: date).lowercased()
        
        return formattedDate
    }
}
