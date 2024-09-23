//
//AsyncURLImage.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/21/24.
//

import SwiftUI

//AsyncImage() takes care of the image loading and basic caching. Given more time I could write an ImageLoader and a URLImageView
struct AsyncURLImage: View {
    
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
            } else if phase.error != nil || url == nil {
                Image.init(systemName: "photo.circle")
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
    }
}
