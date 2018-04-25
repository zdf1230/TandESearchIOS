//
//  MapViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/24/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var travelModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var MapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let placeDetails = (tabBarController as! DetailsViewController).placeDetails
        let lat = placeDetails["geometry"]!["location"]["lat"].doubleValue
        let lng = placeDetails["geometry"]!["location"]["lng"].doubleValue
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15.0)
        let googleMapView = GMSMapView.map(withFrame: MapView.bounds, camera: camera)
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
            break
        default:
            break
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
        travelModeSegmentedControl.selectedSegmentIndex = 0
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
