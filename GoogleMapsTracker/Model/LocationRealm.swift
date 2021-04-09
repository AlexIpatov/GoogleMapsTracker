//
//  LocationRealm.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 06.04.2021.
//

import CoreLocation
import RealmSwift

class EncodedPathRealm: Object {
    @objc dynamic var encodedPath: String = ""
}

