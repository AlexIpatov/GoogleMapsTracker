//
//  Validators.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 10.04.2021.
//

import Foundation
class Validators {
static func isFilled(login: String?, password: String?) -> Bool {
    guard let password = password,
    let login = login,
    password != "",
    login != "" else {
            return false
    }
    return true
}
}
