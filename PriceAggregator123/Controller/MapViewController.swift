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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMap()
        setValueForGPS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.title = "Map"
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
        manager.requestAlwaysAuthorization()
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

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "You need to allow identify location that we can show shops near you.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getShops(latitude: String, longitude: String) {
        guard let url = URL(string: "http://api.walmartlabs.com/v1/stores?format=json&lat=\(latitude)&lon=\(longitude)&apiKey=jx9ztwc42y6mfvvhfa4y87hk") else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            do {
                let json = try JSON(data: data!)
                if json.isEmpty {
                    let alert = UIAlertController(title: "No shops", message: "There are no shops in your area.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                DispatchQueue.main.async {
                    self.setCoordinatesFromJSON(json: json)
                }
            } catch { }
        }.resume()
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
