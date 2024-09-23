//
//  Locatable.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/22/24.
//

import Foundation

protocol Locatable {
    var name: String { get }
    var state: String { get }
    var lat: Double { get }
    var lon: Double { get }
}
