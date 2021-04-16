//
//  LocationManager.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 14.04.2021.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa


final class LocationManager: NSObject {
    static let instance = LocationManager()

    private override init() {
        super.init()
        configureLocationManager()
    }

    var locationManager = CLLocationManager()

    let location = BehaviorRelay<CLLocation?>(value: nil)

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    private func configureLocationManager() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
    }

}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location.accept(locations.last)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
