//
//  MapViewController.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 02.04.2021.
//

import UIKit
import GoogleMaps
import RealmSwift
import RxSwift
import RxCocoa

class MapViewController: UIViewController {
    @IBOutlet var mainRouter: MainRouter!
    private var isTracking: Bool = false
    private let realm = try! Realm()
    private var avatarImage: UIImage? {
        didSet {
            placeMarkWithAvatar.icon = avatarImage
        }
    }
    private(set) lazy var placeMarkWithAvatar = GMSMarker()
    private var locationManager = LocationManager.instance
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private var bag = DisposeBag()
    private lazy var stopButton = UIButton(image: UIImage(systemName: "stop.fill"),
                                           cornerRadius: 35)
    private lazy var startButton = UIButton(image: UIImage(systemName: "play.fill"),
                                            cornerRadius: 35)
    private lazy var showPreviousRoute = UIButton(image: UIImage(systemName: "arrow.counterclockwise"),
                                                  cornerRadius: 20)
    private lazy var logOut = UIButton(image: UIImage(systemName: "figure.wave"),
                                       cornerRadius: 20)
    private lazy var cameraButton = UIButton(image: UIImage(systemName: "camera"),
                                             cornerRadius: 35)
    @IBOutlet weak var mapView: GMSMapView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        setupButtons()
        addButtonTargets()
        configureLocationManager()
        setupAvatar()
    }
    // MARK: - configure location & map
    private func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                // MARK: setup placeMarkWithAvatar position
                self?.placeMarkWithAvatar.position = location.coordinate
                // MARK: setup routePath
                self?.route?.path = self?.routePath
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
            }.disposed(by: bag)
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
        showPreviousRoute.addTarget(self, action: #selector(showPreviousRouteTapped), for: .touchUpInside)
        logOut.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action:  #selector(cameraButtonTapped), for: .touchUpInside)
    }
    // MARK: - Realm methods
    private func savePathToRealm() {
        try! realm.write {
            realm.delete(realm.objects(EncodedPathRealm.self))
            let encodedPath = EncodedPathRealm()
            encodedPath.encodedPath = routePath?.encodedPath() ?? ""
            realm.add(encodedPath)
        }
    }
    private func saveImageToRealm(imageData: Data?) {
        guard let imageData = imageData else { return }
        try! realm.write {
            realm.delete(realm.objects(AvaImageRealm.self))
            let newAvatar = AvaImageRealm()
            newAvatar.avatar = imageData
            realm.add(newAvatar)
        }
    }
    private func setupAvatar()  {
        guard let avaData = realm.objects(AvaImageRealm.self).last?.avatar else { return }
        avatarImage = UIImage(data: avaData)
    }
    // MARK: - Alert
    func showNowTrackingAlert() {
        let alertController = UIAlertController(title: "Tracking in progress!",
                                                message: "Do you want to save the current track?",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.stopTrack()
        }
        let noAction = UIAlertAction(title: "No", style: .default) { [self] (_) in
            isTracking = false
            route?.map = nil
            locationManager.stopUpdatingLocation()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(okAction)
        alertController.addAction(noAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
// MARK: - Actions
extension MapViewController {
    @objc private func startNewTrack() {
        isTracking = true
        route?.map = nil
        route?.strokeColor = .blue
        route = GMSPolyline()
        placeMarkWithAvatar.map = mapView
        routePath = GMSMutablePath()
        route?.map = mapView
        mapView.animate(toZoom: 17)
        locationManager.startUpdatingLocation()
    }
    @objc private func stopTrack() {
        isTracking = false
        route?.map = nil
        placeMarkWithAvatar.map = nil
        locationManager.stopUpdatingLocation()
        savePathToRealm()
    }
    @objc private func showPreviousRouteTapped() {
        guard !isTracking else { showNowTrackingAlert()
            return }
        let encodedPath = realm.objects(EncodedPathRealm.self)
        guard encodedPath.count != 0 else { return }
        route?.map = nil
        routePath = GMSMutablePath(fromEncodedPath: encodedPath[0].encodedPath)
        route?.map = mapView
        route?.path = routePath
        setUpСameraForPreviousRoute()
    }
    @objc private func logOutTapped() {
        UserDefaults.standard.set(false, forKey: "isLogin")
        mainRouter.toLaunch()
    }
    @objc private func cameraButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
}

// MARK: - Setup UI
extension MapViewController {
    private func setupButtons() {
        mapView.addSubview(cameraButton)
        mapView.addSubview(logOut)
        mapView.addSubview(showPreviousRoute)
        mapView.addSubview(stopButton)
        mapView.addSubview(startButton)
        NSLayoutConstraint.activate([
            logOut.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 100),
            logOut.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20),
            logOut.widthAnchor.constraint(equalToConstant: 40),
            logOut.heightAnchor.constraint(equalTo: logOut.widthAnchor),

            showPreviousRoute.topAnchor.constraint(equalTo: logOut.bottomAnchor, constant: 20),
            showPreviousRoute.rightAnchor.constraint(equalTo: logOut.rightAnchor),
            showPreviousRoute.widthAnchor.constraint(equalTo: logOut.widthAnchor),
            showPreviousRoute.heightAnchor.constraint(equalTo: logOut.widthAnchor),

            stopButton.widthAnchor.constraint(equalToConstant: 70),
            stopButton.heightAnchor.constraint(equalTo: stopButton.widthAnchor),
            stopButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            stopButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20),

            startButton.widthAnchor.constraint(equalToConstant: 70),
            startButton.heightAnchor.constraint(equalTo: stopButton.widthAnchor),
            startButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            startButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20),

            cameraButton.widthAnchor.constraint(equalToConstant: 70),
            cameraButton.heightAnchor.constraint(equalTo: cameraButton.widthAnchor),
            cameraButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 100),
            cameraButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20)
        ])
    }
}
// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension MapViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let image = self?.extractImage(from: info) else { return }
            let mapImage = image.resizeForMapMark(newSize: CGSize(width: 50, height: 50))
            self?.saveImageToRealm(imageData: mapImage.pngData())
            self?.avatarImage = mapImage
        }
    }

    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}
