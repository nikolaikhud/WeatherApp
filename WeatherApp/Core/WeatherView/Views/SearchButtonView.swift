//
//  SearchButtonView.swift
//  WeatherApp
//
//  Created by Nikolai Khudiakov on 9/24/24.
//

import SwiftUI
import UIKit

// Utilized UIKit to meet the challenge requirements. Otherwise I'd prefer to implement the Search Button utilizing SwiftUI
struct SearchButtonWrapper: UIViewRepresentable {
    var onTap: () -> Void
    
    func makeUIView(context: Context) -> SearchButtonView {
        let searchButtonView = SearchButtonView()
        searchButtonView.configure(onTap: onTap)
        return searchButtonView
    }
    
    func updateUIView(_ uiView: SearchButtonView, context: Context) {
        
    }
}

class SearchButtonView: UIView {
    
    // MARK: - Properties
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setBackgroundColor(UIColor.systemGray5, for: .normal)
        button.setBackgroundColor(UIColor.systemGray4, for: .highlighted)
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Search by city/town name"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    var onTap: (() -> Void)?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        addSubview(button)
        button.addSubview(iconImageView)
        button.addSubview(titleLabel)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Button constraints
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Icon constraints
            iconImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 14),
            iconImageView.heightAnchor.constraint(equalToConstant: 14),
            
            // Title constraints
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        onTap?()
    }
    
    // MARK: - Public Methods
    func configure(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let image = UIImage(color: color)
        setBackgroundImage(image, for: state)
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
