//
//  SceneDelegate.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 15/02/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        configureNavigationBarAppearance()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = SplashViewController()
        self.window = window
        window.makeKeyAndVisible()
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        let blurEffect = UIBlurEffect()
        appearance.backgroundEffect = blurEffect
        appearance.shadowColor = .clear
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
    }

    func setRootViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = viewController
        if animated {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
        window.makeKeyAndVisible()
    }
}
