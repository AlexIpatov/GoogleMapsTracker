//
//  User.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 10.04.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var  login: String = ""
    @objc dynamic var  password: String = ""

    override class func primaryKey() -> String? {
        "login"
    }
}
