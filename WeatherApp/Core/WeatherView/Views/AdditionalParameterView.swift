//
//  AdditionalParameterView.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/19/24.
//

import Foundation
import SwiftUI


struct AdditionalParameterView: View {
    
    let parameter: String
    let value: String
    
    var body: some View {
        VStack {
            Text(parameter)
                .font(.system(size: 20))
            Text(value)
                .font(.system(size: 40))
        }
        .foregroundStyle(.accent)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
