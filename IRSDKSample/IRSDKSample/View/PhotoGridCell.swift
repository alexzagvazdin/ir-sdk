//
//  PhotoGridCell.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 23/12/2022.
//

import UIKit

class PhotoGridCell: UITableViewCell {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var trashButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.imageColorTransformer = UIConfigurationColorTransformer { _ in .systemRed }
        configuration.buttonSize = .medium
        configuration.image = UIImage(
            systemName: "trash",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )
        
        let action = UIAction { [weak self] _ in self?.didTapTrashButton?() }
        
        return UIButton(configuration: configuration, primaryAction: action)
    }()
    
    var photoGrid: PhotoGrid? {
        didSet {
            updateTitle()
            updateSubtitle()
        }
    }
    
    var didTapTrashButton: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        stackView.addArrangedSubview(labelStackView)
        stackView.addArrangedSubview(trashButton)
        
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(subtitleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateTitle() {
        titleLabel.text = "\(photoGrid?.index ?? 0). Photo grid"
    }
    
    private func updateSubtitle() {
        let id = photoGrid?.id.split(separator: "-").first ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let time = dateFormatter.string(from: photoGrid?.createdAt ?? Date())
        
        subtitleLabel.text = "\(id) • \(time)"
    }
}

