//
//  MainRouter.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 11.04.2021.
//

import UIKit

final class MainRouter: BaseRouter {
    func toLaunch() {
        let controller = UIStoryboard(name: "Auth", bundle: nil)
            .instantiateViewController(LoginViewController.self)
        setAsRoot(UINavigationController(rootViewController: controller))
    }
}
