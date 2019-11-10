//
//  ViewController.swift
//  GoogleMapsDemo
//
//  Created by Shubham Vinod Kamdi on 09/11/19.
//  Copyright © 2019 Shubham Vinod Kamdi. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var sourceTextfield: UITextField!
    @IBOutlet weak var destinationTextfield: UITextField!
    
    var sourceCordinate: CLLocationCoordinate2D!
    var destinationCordinate: CLLocationCoordinate2D!
    var locationManager: CLLocationManager!
    override func viewDidLoad(){
        super.viewDidLoad()
        sourceTextfield.delegate = self
        destinationTextfield.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
    }

    @IBAction func findRoute(){
        if sourceCordinate != nil && destinationCordinate != nil{
            let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutesViewController") as! RoutesViewController
            VC.origin = sourceCordinate
            VC.destination = destinationCordinate
            self.present(VC, animated: true)
        }else{
            print("BOTH_CORDINATES_NOT_PRESENT")
        }
    }

}

extension ViewController{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapsViewController") as! MapsViewController
        VC.prevVCObj = self
        if textField == sourceTextfield{
            VC.mapFor = "SOURCE_LOCATION"
        }else{
            VC.mapFor = "DESTINATION_LOCATION"
        }
        self.present(VC, animated: true)
        
    }
}
