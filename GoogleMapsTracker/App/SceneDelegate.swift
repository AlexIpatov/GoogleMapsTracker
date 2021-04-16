//
//  SceneDelegate.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 02.04.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let controller: UIViewController
                      if UserDefaults.standard.bool(forKey: "isLogin") {
                          controller = UIStoryboard(name: "Main", bundle: nil)
                              .instantiateViewController(MapViewController.self)
                      } else {
                          controller = UIStoryboard(name: "Auth", bundle: nil)
                              .instantiateViewController(LoginViewController.self)
                      }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = UINavigationController(rootViewController: controller)
                      window?.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        self.window?.viewWithTag(1)?.removeFromSuperview()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window!.frame
        blurEffectView.tag = 1
        self.window?.addSubview(blurEffectView)
    }

}

