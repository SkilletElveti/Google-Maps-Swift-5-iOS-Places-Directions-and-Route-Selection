//
//  MapsViewController.swift
//  GoogleMapsDemo
//
//  Created by Shubham Vinod Kamdi on 09/11/19.
//  Copyright © 2019 Shubham Vinod Kamdi. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps

class MapsViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var mapFor: String!
    var locationManager: CLLocationManager!
    var geocoder: GMSGeocoder!
    var permissionFlag: Bool!
    var googleMaps: GMSMapView!
    var pickupCoordinate: CLLocationCoordinate2D!
    var marker: GMSMarker!
    var currentLocation: CLLocation!
    var address: String!
    var city: String!
    var prevVCObj: ViewController!
    var fromPlacesVC: Bool = false
    var firstTimeViewDidAppearCallFLag: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        city = ""
        address = ""
        geocoder = GMSGeocoder()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        searchBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(placeApiVC)))
    }
    
    @objc func placeApiVC(){
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlacesViewController") as! PlacesViewController
        VC.prevVCObj = self
        self.present(VC, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("EROOR \(error)")
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted{
            redirectToSettings()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status{
            
        case .authorizedAlways:
            if manager.location != nil{
                
                self.permissionFlag = true
                self.currentLocation = manager.location
                
            }else{
                
                self.dismiss(animated: true, completion: nil)
            
            }
            break
            
        case .authorizedWhenInUse:
            if manager.location != nil{
                
                self.permissionFlag = true
                self.currentLocation = manager.location
           
            }else{
            
                self.dismiss(animated: true, completion: nil)
            
            }
            
            break
            
        case .notDetermined:
            self.permissionFlag = false
            redirectToSettings()
            break
            
        case .denied:
            self.permissionFlag = false
            redirectToSettings()
            break
            
        case .restricted:
            self.permissionFlag = false
            redirectToSettings()
            break
            
        default:
            print("ERROR_TRY_AGAIN_LATER")
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if firstTimeViewDidAppearCallFLag{
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined{
                
                self.permissionFlag = false
                redirectToSettings()
                
            }else{
                
                self.permissionFlag = true
                googleMaps = GMSMapView()
                googleMaps = GMSMapView(frame: self.mapView.frame)
                self.googleMaps?.isMyLocationEnabled = true
                view.addSubview(googleMaps)
                recenterMaps()
                
            }
            firstTimeViewDidAppearCallFLag = false
        }else{
            //RETAINING MAP STATE
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined{
                
                self.permissionFlag = false
                redirectToSettings()
                
            }
        }
        
    }
    
    
    func recenterMaps(){
        
        self.pickupCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        if pickupCoordinate != nil{
            
                let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 15.0)
                googleMaps.camera = camera
            googleMaps.mapType = .normal
            geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), completionHandler: {
                response, error in
                if error == nil{
                    if let resultAdd = response?.firstResult(){
                        self.googleMaps.delegate = self
                        let lines = resultAdd.lines! as [String]
                        self.city = resultAdd.locality
                        print("ADDRESS => \(lines.joined(separator: "\n"))")
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
                        marker.snippet = lines.joined(separator: "\n")
                        marker.title = "\(resultAdd.locality ?? "Unavailable")"
                        self.address = lines.joined(separator: "\n")
                        marker.map = self.googleMaps
                    }else{
                        print("ERROR_PLEASE_TRY_AGAIN_LATER")
                    }
                    
                }
            })
            
        }else{
            
           print("CURRENT_LOCATION_OBJECT_IS_NIL")
            
        }
        
        
        
    }
    
    func fromPlacesVCRecenter(){
        if fromPlacesVC{
            let camera = GMSCameraPosition.camera(withLatitude: pickupCoordinate.latitude, longitude: pickupCoordinate.longitude, zoom: 15.0)
            googleMaps.camera = camera
            googleMaps.mapType = .normal
            geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: pickupCoordinate.latitude, longitude: pickupCoordinate.longitude), completionHandler: {
                response, error in
                if error == nil{
                    if let resultAdd = response?.firstResult(){
                        self.googleMaps.delegate = self
                        let lines = resultAdd.lines! as [String]
                        self.city = resultAdd.locality
                        print("ADDRESS => \(lines.joined(separator: "\n"))")
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: self.pickupCoordinate.latitude, longitude: self.pickupCoordinate.longitude)
                        marker.snippet = lines.joined(separator: "\n")
                        marker.title = "\(resultAdd.locality ?? "Unavailable")"
                        self.address = lines.joined(separator: "\n")
                        marker.map = self.googleMaps
                    }else{
                        print("ERROR_PLEASE_TRY_AGAIN_LATER")
                    }
                    
                }
            })
            fromPlacesVC = false
            
        }
    }
    
    func redirectToSettings(){
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined{
            self.permissionFlag = false
            let alertController = UIAlertController(title: "Location Access Denied or Restricted",
                                                    message: "Please enable location and try again",
                                                    preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: { _ in
                        })
                        self.dismiss(animated: true, completion: nil)
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clear()
                    } else {
                        UIApplication.shared.openURL(appSettings as URL)
                        self.dismiss(animated: true, completion: nil)
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clear()
                    }
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                _ in
                self.dismiss(animated: true, completion: {
                    print("DISMISSING_VIEWCONTROLLER")
                })
            })
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func grabLocation(){
        if pickupCoordinate != nil{
            switch mapFor{
                
            case "SOURCE_LOCATION":
                prevVCObj.sourceTextfield.text = address
                prevVCObj.sourceCordinate = pickupCoordinate
                self.dismiss(animated: true, completion: nil)
                break
                
            case "DESTINATION_LOCATION":
                prevVCObj.destinationTextfield.text = address
                prevVCObj.destinationCordinate = pickupCoordinate
                self.dismiss(animated: true, completion: nil)
                break
                
            default:
                print("UNRECONGNIZED_MAPFOR_IDENTIFIER")
            }
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension MapsViewController{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //Setting the marker on tap!
        
        self.pickupCoordinate = coordinate
        print("LOCATION_UPDATE TO")
        print("LAT: \(coordinate.latitude)")
        print("LONG: \(coordinate.longitude)")
        print("REVERSE_GEOCODING")
        geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: {
            response, error in
            if error == nil{
                if let resultAdd = response?.firstResult(){
                    mapView.clear()
                    let lines = resultAdd.lines! as [String]
                    self.city = resultAdd.locality
                    print("ADDRESS => \(lines.joined(separator: "\n"))")
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    marker.snippet = lines.joined(separator: "\n")
                    marker.title = "\(resultAdd.locality ?? "Unavailable")"
                    self.address = lines.joined(separator: "\n")
                    marker.map = mapView
                }else{
                    print("ERROR_PLEASE_TRY_AGAIN_LATER")
                }
                
            }
        })
        
    }
}
