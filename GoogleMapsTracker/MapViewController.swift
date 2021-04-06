//
//  MapViewController.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 02.04.2021.
//

import UIKit
import GoogleMaps
import RealmSwift

class MapViewController: UIViewController {
    private var isTracking: Bool = false
    private let realm = try! Realm()
    private var locationManager: CLLocationManager?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?

    private lazy var stopButton = UIButton(image: UIImage(systemName: "stop.fill"), cornerRadius: 35)
    private lazy var startButton = UIButton(image: UIImage(systemName: "play.fill"), cornerRadius: 35)
    @IBOutlet weak var mapView: GMSMapView!
    @IBAction func showPreviousRoute(_ sender: Any) {
        guard  !isTracking  else {showNowTrackingAlert()
            return }
        let encodedPath = realm.objects(EncodedPathRealm.self)
        guard encodedPath.count != 0 else { return }
        route?.map = nil
        routePath = GMSMutablePath(fromEncodedPath: encodedPath[0].encodedPath)
        route?.map = mapView
        route?.path = routePath
        setUpСameraForPreviousRoute()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        setupButtons()
        addButtonTargets()
        configureLocationManager()
        locationManager?.requestLocation()
        print(realm.configuration.fileURL!)
    }
    // MARK: - configure location & map
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.delegate = self
    }
    private func configureMap() {
        mapView.animate(toZoom: 17)
    }
    // MARK: - Methods
    private func setUpСameraForPreviousRoute() {
        let bounds = GMSCoordinateBounds(path: routePath!)
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    private func addButtonTargets() {
        startButton.addTarget(self, action: #selector(startNewTrack), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTrack), for: .touchUpInside)
    }
    private func addMarkerToPosition(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
    }
    private func savePathToRealm() {
        try! realm.write {
            realm.deleteAll()
            let encodedPath = EncodedPathRealm()
            encodedPath.encodedPath = routePath?.encodedPath() ?? ""
            realm.add(encodedPath)
        }
    }
    func showNowTrackingAlert() {
        let alertController = UIAlertController(title: "Tracking in progress!", message: "Do you want to save the current track?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.stopTrack()
        }
        let noAction = UIAlertAction(title: "No", style: .default) { [self] (_) in
            isTracking = false
            route?.map = nil
            locationManager?.stopUpdatingLocation()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(okAction)
        alertController.addAction(noAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentCoordinate = locations.last?.coordinate else { return }
        routePath?.add(currentCoordinate)
        route?.path = routePath
        mapView.animate(toLocation: currentCoordinate)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
// MARK: - Actions
extension MapViewController {
    @objc private func startNewTrack() {
        isTracking = true
        route?.map = nil
        route?.strokeColor = .blue
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        mapView.animate(toZoom: 17)
        locationManager?.startUpdatingLocation()
    }
    @objc private func stopTrack() {
        isTracking = false
        route?.map = nil
        locationManager?.stopUpdatingLocation()
        savePathToRealm()
    }
}
// MARK: - Setup UI
extension MapViewController {
    private func setupButtons() {
        mapView.addSubview(stopButton)
        mapView.addSubview(startButton)
        NSLayoutConstraint.activate([
            stopButton.widthAnchor.constraint(equalToConstant: 70),
            stopButton.heightAnchor.constraint(equalTo: stopButton.widthAnchor),
            stopButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            stopButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20),

            startButton.widthAnchor.constraint(equalToConstant: 70),
            startButton.heightAnchor.constraint(equalTo: stopButton.widthAnchor),
            startButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            startButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20)
        ])
    }
}
