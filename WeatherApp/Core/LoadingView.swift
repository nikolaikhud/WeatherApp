//
//  LoadingView.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/23/24.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray4)
                .ignoresSafeArea()
                .opacity(0.3)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.accent))
                .scaleEffect(2)
        }
    }
}
