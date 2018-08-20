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
import MapKit

class MapViewController: UIViewController {
    
    let manager = CLLocationManager()
    @IBOutlet weak var mapkit: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestAlwaysAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.requestLocation()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(locations.first!.coordinate, 100_000, 100_000)
        mapkit.setRegion(coordinateRegion, animated: true)
        if let location = locations.first {
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
                self.setCoordinatesFromJSON(json: json)
            } catch { }
        }.resume()
    }
    
    func setCoordinatesFromJSON(json: JSON) {
        var i = 0
        while json[i] != JSON.null {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: json[i]["coordinates"][1].double!, longitude: json[i]["coordinates"][0].double!)
            annotation.title = json[i]["name"].string!
            mapkit.addAnnotation(annotation)
            i += 1
        }
    }
}
