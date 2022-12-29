//
//  LoginViewController.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 27/12/2022.
//

import UIKit
import IRSDK

class LoginViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .black)
        label.text = "Welcome!"
        return label
    }()
    
    private lazy var logInButton: UIButton = {
        var attributeContainer = AttributeContainer()
        attributeContainer.font = .systemFont(ofSize: 16, weight: .bold)
        
        var configuration = UIButton.Configuration.filled()
        configuration.attributedTitle = AttributedString("Log In", attributes: attributeContainer)
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .large

        let action = UIAction { [weak self] _ in self?.logIn() }
        
        return UIButton(configuration: configuration, primaryAction: action)
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(logInButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func logIn() {
        IRSDK.authenticate(with: AppToken.generateFake()) { result in
            switch result {
            case .success:
                print("Succesfully logged in.")
                (UIApplication.shared.delegate as? AppDelegate)?.navigateToHome()
            case .failure(let error):
                print("Failed to log in (\(error)).")
            }
        }
    }
}
