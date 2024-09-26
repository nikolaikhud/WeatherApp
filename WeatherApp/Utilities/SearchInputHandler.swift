//
//  SearchInputHandler.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/26/24.
//

import Foundation

struct SearchInputHandler {
    
    static func formatCityInput(for input: String) -> String {
        var formattedInput = clearSearchInput(input)
        formattedInput = formatCityName(formattedInput)
        return formattedInput
    }
    
    private static func clearSearchInput(_ input: String) -> String {
        // Trim leading and trailing whitespace
        var cleanedString = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Replace multiple spaces with a single space
        cleanedString = cleanedString.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Replace dashes with spaces
        cleanedString = cleanedString.replacingOccurrences(of: "-", with: " ")
        
        // Remove special characters
        cleanedString = cleanedString.replacingOccurrences(of: "[^a-zA-Z0-9\\s-]", with: "", options: .regularExpression)
        
        // Convert to lowercase
        cleanedString = cleanedString.lowercased()
        
         return cleanedString
    }
    
    // The Geo API does not allow city names consisting of two or more words to be passed as a single, unseparated word. Below are 100 of the most popular US cities with multi-word names to cover most cases. In a real-world application, it would be better to handle this issue on the server side.
    private static func formatCityName(_ cityName: String) -> String {
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
        
        return knownCityNames[cityName.lowercased()] ?? cityName
    }
}
