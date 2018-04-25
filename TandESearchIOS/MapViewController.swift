//
//  MapViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/24/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var travelModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var MapView: UIView!
    var googleMapView: GMSMapView!
    var originLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let placeDetails = (tabBarController as! DetailsViewController).placeDetails
        let lat = placeDetails["geometry"]!["location"]["lat"].doubleValue
        let lng = placeDetails["geometry"]!["location"]["lng"].doubleValue
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15.0)
        googleMapView = GMSMapView.map(withFrame: MapView.bounds, camera: camera)
        googleMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.map = googleMapView
        
        MapView.addSubview(googleMapView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func autocompleteClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func travelModeChanged(_ sender: Any) {
        switch travelModeSegmentedControl.selectedSegmentIndex {
        case 0:
            getDirections(mode: "driving")
        case 1:
            getDirections(mode: "bicycling")
        case 2:
            getDirections(mode: "transit")
        case 3:
            getDirections(mode: "walking")
        default:
            break
        }
    }
    
    func getDirections(mode: String) {
        googleMapView.clear()
        var marker = GMSMarker(position: originLocation)
        marker.map = googleMapView
        
        let placeDetails = (tabBarController as! DetailsViewController).placeDetails
        let lat = placeDetails["geometry"]!["location"]["lat"].doubleValue
        let lng = placeDetails["geometry"]!["location"]["lng"].doubleValue
        let destinationLocationString = String(lat) + "," + String(lng)
        let originLocationString = String(originLocation.latitude) + "," + String(originLocation.longitude)
        
        marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        marker.map = googleMapView
        
        let url = URL(string: Constants.serverUrlPrefix + "getdirections")
        let parameters: Parameters = ["originlocation": originLocationString,
                                      "destinationlocation": destinationLocationString,
                                      "mode": mode]
        
        Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
            if let directions = response.result.value {
                let overviewPolyline = directions["routes"][0]["overview_polyline"]["points"].stringValue
                let path = GMSPath(fromEncodedPath: overviewPolyline)
                
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = .blue
                polyline.strokeWidth = 3.0
                polyline.geodesic = true
                polyline.map = self.googleMapView
                
                var cood = directions["routes"][0]["bounds"]["southwest"]
                let left = CLLocationCoordinate2D(latitude: cood["lat"].doubleValue, longitude: cood["lng"].doubleValue)
                cood = directions["routes"][0]["bounds"]["northeast"]
                let right = CLLocationCoordinate2D(latitude: cood["lat"].doubleValue, longitude: cood["lng"].doubleValue)
                let bounds = GMSCoordinateBounds(coordinate: left, coordinate: right)
                let update = GMSCameraUpdate.fit(bounds)
                self.googleMapView.animate(with: update)
            }
        }
        
    }

}

extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        if let address = place.formattedAddress {
            fromTextField.text = address
        }
        else {
            fromTextField.text = place.name
        }
        travelModeSegmentedControl.isEnabled = true
        travelModeSegmentedControl.selectedSegmentIndex = 0
        originLocation = place.coordinate
        getDirections(mode: "driving")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
