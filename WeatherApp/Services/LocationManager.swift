//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/22/24.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    let viewState = SharedViewState.shared
    
    func checkLocationAuthorization() {
        viewState.state = .loading
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            
        default:
            break
        
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastKnownLocation = location.coordinate
            manager.stopUpdatingLocation()
            self.viewState.dismissLoadingWithAsync()
        }
    }
}
