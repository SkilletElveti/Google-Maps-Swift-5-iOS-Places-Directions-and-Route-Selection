//
//  PlacesViewController.swift
//  GoogleMapsDemo
//
//  Created by Shubham Vinod Kamdi on 10/11/19.
//  Copyright © 2019 Shubham Vinod Kamdi. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var placesTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var placesClient: GMSPlacesClient!
    var likelyPlaces: [SearchResult] = []
    var prevVCObj: MapsViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        placesTable.delegate = self
        placesTable.dataSource = self
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        getPlaces()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        getPlaces()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getPlaces()
    }
    
    func getPlaces(){
        
        placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(self.searchBar.text!, bounds: nil, filter: nil, callback: {
            (Result, error) -> Void in
            if Result != nil{
                for result in Result!{
                    
                    if let result = result as? GMSAutocompletePrediction{
                        self.likelyPlaces.append(SearchResult(placeText: result.attributedFullText.string, placeID: result.placeID))
                    }
                    
                }
                
                self.placesTable.delegate = self
                self.placesTable.dataSource = self
                self.placesTable.reloadData()
                
            }else{
                print(error)
            }
        })
    }

}

extension PlacesViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Places", for: indexPath)
        cell.textLabel?.text = self.likelyPlaces[indexPath.row].placeText
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        placesClient.lookUpPlaceID(likelyPlaces[indexPath.row].placeID, callback: {
            (result, error) -> Void in
            if error == nil{
                
                print(result?.coordinate.latitude as Any?)
                print(result?.coordinate.longitude as Any?)
                self.prevVCObj.pickupCoordinate = CLLocationCoordinate2DMake((result?.coordinate.latitude)!, (result?.coordinate.longitude)!)
                self.prevVCObj.fromPlacesVC = true
                self.prevVCObj.address = self.likelyPlaces[indexPath.row].placeText
                self.prevVCObj.fromPlacesVCRecenter()
                self.dismiss(animated: true, completion: nil)
            }else{
                return
            }
        })
    }
    
}

struct SearchResult{
    var placeText: String!
    var placeID: String!
    
    init(placeText: String!, placeID: String!){
        self.placeText = placeText
        self.placeID = placeID
    }
    
}
