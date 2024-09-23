//
//  UIApplication.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/19/24.
//

import Foundation
import UIKit

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
