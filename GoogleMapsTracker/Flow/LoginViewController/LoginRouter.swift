//
//  LoginRouter.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 11.04.2021.
//

import UIKit

final class LoginRouter: BaseRouter {
    func toMain() {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(MapViewController.self)
        setAsRoot(UINavigationController(rootViewController: controller))
    }
}
