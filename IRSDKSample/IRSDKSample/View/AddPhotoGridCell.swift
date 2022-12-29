//
//  AddPhotoGridCell.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 23/12/2022.
//

import UIKit

class AddPhotoGridCell: UITableViewCell {
    
    private lazy var cameraButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.buttonSize = .large
        configuration.image = UIImage(
            systemName: "camera.fill",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )
        
        let action = UIAction { [weak self] _ in self?.didTapCameraButton?() }
        
        return UIButton(configuration: configuration, primaryAction: action)
    }()
    
    var didTapCameraButton: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            cameraButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            cameraButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
