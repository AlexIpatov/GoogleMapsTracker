//
//  MapViewController.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 02.04.2021.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    private var locationManager: CLLocationManager?

    @IBOutlet weak var mapView: GMSMapView!
    @IBAction func startTrackLocation(_ sender: Any) {
        locationManager?.startUpdatingLocation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
        locationManager?.requestLocation()
    }
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
    }
    private func configureMap() {
        mapView.animate(toZoom: 17)
    }
    private func addMarkerToPosition(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentCoordinate = locations.last?.coordinate else { return }
        mapView.animate(toLocation: currentCoordinate)
        addMarkerToPosition(position: currentCoordinate)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}



