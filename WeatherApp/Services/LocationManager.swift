//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/22/24.
//

import Foundation
import Combine
import CoreLocation

protocol LocationManagerProtocol {
    var lastKnownLocation: CLLocationCoordinate2D? { get }
    var lastKnownLocationPublisher: Published<CLLocationCoordinate2D?>.Publisher { get }
    var manager: CLLocationManager { get }
    var authorizationStatus: CLAuthorizationStatus { get }
}

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject, LocationManagerProtocol {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var lastKnownLocationPublisher: Published<CLLocationCoordinate2D?>.Publisher { $lastKnownLocation }
    var manager = CLLocationManager()
//    let viewState = SharedViewState.shared
    
    override init() {
        super.init()
        manager.delegate = self
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        self.authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            
        default:

            manager.stopUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastKnownLocation = location.coordinate
            manager.stopUpdatingLocation()
        }
    }
}
