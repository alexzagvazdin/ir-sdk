//
//  AppDelegate.swift
//  IRSDKSample
//
//  Created by Marcin Hatalski on 23/12/2022.
//

import IRSDK
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        IRSDK.authDelegate = self
        IRSDK.initialize { result in
            switch result{
            case .success( _):
                print("Successfully initialized IR SDK.")
            case .failure(let error):
                print("Failed to initialize IR SDK (\(error)).")
            }
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        if IRSDK.isAuthenticated {
            navigateToHome()
        } else {
            navigateToLogin()
        }
        
        return true
    }
    
    func navigateToHome() {
        replaceRootViewController(with: UINavigationController(rootViewController: HomeViewController()))
    }
    
    func navigateToLogin() {
        replaceRootViewController(with: LoginViewController())
    }
    
    private func replaceRootViewController(with viewController: UIViewController) {
        guard let window = window else { return }
        
        guard window.rootViewController != nil else {
            window.rootViewController = viewController
            return
        }
        
        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.curveEaseInOut, .transitionFlipFromLeft],
            animations: { window.rootViewController = viewController }
        )
    }
}

extension AppDelegate: AuthDelegate {
    
    func didRequestNewAppToken() {
        print("didRequestNewAppToken()")
    }
}
