//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/18/24.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WeatherView(viewModel: coordinator.weatherViewModel)
            }
            .environmentObject(coordinator)
        }
    }
}
