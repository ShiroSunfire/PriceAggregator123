//
//  MapViewController.swift
//  PriceAggregator123
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    let manager = CLLocationManager()
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    let gjson = GetJSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMap()
        setValueForGPS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.title = NSLocalizedString("Shops", comment: "")
        manager.requestLocation()
    }
    
    private func createMap() {
        mapView = GMSMapView(frame: self.view.frame)
        mapView.delegate = self
        self.view.addSubview(mapView)
    }
    
    private func setValueForGPS() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        placesClient = GMSPlacesClient.shared()
    }
}

extension MapViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let info = Bundle.main.loadNibNamed("InfoPlace", owner: nil, options: nil)?.first as! InfoPlace
        info.setValues(name: marker.title!, address: marker.userData as! String, phoneNumber: marker.snippet!)
        info.frame.size = CGSize(width: 200, height: 70)
        return info
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 7.0)
            mapView.camera = camera
            getShops(latitude: String(location.coordinate.latitude), longitude: String(location.coordinate.longitude))
        }
    }
    
    private func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("You need to allow identify location that we can show shops near you.", comment: ""))
    }

    func returnJSON(_ json: JSON) {
        if json == JSON.null {
            showAlert(title: NSLocalizedString("Offline", comment: ""), message: NSLocalizedString("You can see products that have been added to favorites or to basket", comment: ""))
        }
        if json.isEmpty {
            showAlert(title: NSLocalizedString("No shops", comment: ""), message: NSLocalizedString("There are no shops in your area.", comment: ""))
            return
        }
        DispatchQueue.main.async {
            self.setCoordinatesFromJSON(json: json)
        }
    }
    
    func getShops(latitude: String, longitude: String) {
        gjson.getItems(with: URL(string: "http://api.walmartlabs.com/v1/stores?format=json&lat=\(latitude)&lon=\(longitude)&apiKey=jx9ztwc42y6mfvvhfa4y87hk"), completion: returnJSON(_:))
    }
    
    func setCoordinatesFromJSON(json: JSON) {
        var i = 0
        while json[i] != JSON.null {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: json[i]["coordinates"][1].double!, longitude: json[i]["coordinates"][0].double!)
            marker.title = json[i]["name"].string!
            marker.snippet = json[i]["phoneNumber"].string!
            marker.userData = json[i]["streetAddress"].string!
            marker.map = mapView
            i += 1
        }
    }
}
