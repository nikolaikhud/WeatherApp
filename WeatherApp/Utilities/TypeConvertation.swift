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
    
    // The Geo API does not allow city names consisting of two or more words to be passed as a single, unseparated word. Below are 100 of the most popular US cities with multi-word names to cover most cases. In a real-world application, it would be better to handle this issue on the server side.
    static func formatCityName(_ cityName: String) -> String {
        // Dictionary of 100 known city names with separators
        let knownCityNames = [
            "newyork": "New York",
            "losangeles": "Los Angeles",
            "sanfrancisco": "San Francisco",
            "sandiego": "San Diego",
            "sanjose": "San Jose",
            "lasvegas": "Las Vegas",
            "sanantonio": "San Antonio",
            "santamonica": "Santa Monica",
            "fortworth": "Fort Worth",
            "longbeach": "Long Beach",
            "virginiabeach": "Virginia Beach",
            "kansascity": "Kansas City",
            "oklahomacity": "Oklahoma City",
            "saltlakecity": "Salt Lake City",
            "batonrouge": "Baton Rouge",
            "santabarbara": "Santa Barbara",
            "neworleans": "New Orleans",
            "grandrapids": "Grand Rapids",
            "littlerock": "Little Rock",
            "sanbernardino": "San Bernardino",
            "coloradosprings": "Colorado Springs",
            "corpuschristi": "Corpus Christi",
            "palmsprings": "Palm Springs",
            "siouxfalls": "Sioux Falls",
            "desmoines": "Des Moines",
            "greenbay": "Green Bay",
            "santacruz": "Santa Cruz",
            "grandprairie": "Grand Prairie",
            "westpalmbeach": "West Palm Beach",
            "stpetersburg": "St. Petersburg",
            "santaclara": "Santa Clara",
            "lakecharles": "Lake Charles",
            "fortlauderdale": "Fort Lauderdale",
            "saintpaul": "Saint Paul",
            "newhaven": "New Haven",
            "fortcollins": "Fort Collins",
            "jerseycity": "Jersey City",
            "sanmateo": "San Mateo",
            "sanmarcos": "San Marcos",
            "newportbeach": "Newport Beach",
            "santafe": "Santa Fe",
            "sanclemente": "San Clemente",
            "sanleandro": "San Leandro",
            "sanrafael": "San Rafael",
            "sanramon": "San Ramon",
            "santarosa": "Santa Rosa",
            "sangabriel": "San Gabriel",
            "westcovina": "West Covina",
            "northcharleston": "North Charleston",
            "newbrunswick": "New Brunswick",
            "portsaintlucie": "Port Saint Lucie",
            "rockhill": "Rock Hill",
            "coralsprings": "Coral Springs",
            "santaclarita": "Santa Clarita",
            "sandysprings": "Sandy Springs",
            "southbend": "South Bend",
            "sanangelo": "San Angelo",
            "grandjunction": "Grand Junction",
            "fortmyers": "Fort Myers",
            "palmbeachgardens": "Palm Beach Gardens",
            "royalpalmbeach": "Royal Palm Beach",
            "greatfalls": "Great Falls",
            "grandforks": "Grand Forks",
            "collegestation": "College Station",
            "olivebranch": "Olive Branch",
            "bowlinggreen": "Bowling Green",
            "baycity": "Bay City",
            "cedarrapids": "Cedar Rapids",
            "hiltonheadisland": "Hilton Head Island",
            "westvalleycity": "West Valley City",
            "westjordan": "West Jordan",
            "sanluisobispo": "San Luis Obispo",
            "eastlansing": "East Lansing",
            "portorange": "Port Orange",
            "mountpleasant": "Mount Pleasant",
            "panamacitybeach": "Panama City Beach",
            "lincolnpark": "Lincoln Park",
            "sanbruno": "San Bruno",
            "missionviejo": "Mission Viejo",
            "westnewyork": "West New York",
            "crystallake": "Crystal Lake",
            "eaglepass": "Eagle Pass",
            "redwoodcity": "Redwood City",
            "roundrock": "Round Rock",
            "castlerock": "Castle Rock",
            "twinfalls": "Twin Falls",
            "johnscreek": "Johns Creek",
            "sugarland": "Sugar Land",
            "sanbuenaventura": "San Buenaventura",
            "fountainvalley": "Fountain Valley",
            "sanfernando": "San Fernando"
        ]
        
        print(knownCityNames[cityName.lowercased()] as Any)
        return knownCityNames[cityName.lowercased()] ?? cityName
    }
}
