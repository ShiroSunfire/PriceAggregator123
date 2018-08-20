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
        manager.requestWhenInUseAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.requestLocation()
    }
    
    func getLocation() {
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapkit.setCenter(locations.first!.coordinate, animated: true)
        if let location = locations.first {
            getShops(latitude: String(location.coordinate.latitude), longitude: String(location.coordinate.longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getShops(latitude: String, longitude: String) {
        guard let url = URL(string: "http://api.walmartlabs.com/v1/stores?format=json&lat=\(latitude)&lon=\(longitude)&apiKey=jx9ztwc42y6mfvvhfa4y87hk") else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, responce, error) in
            do {
                let json = try JSON(data: data!)
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
