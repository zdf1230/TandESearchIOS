//
//  ViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/17/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import McPicker
import EasyToast
import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON
import GooglePlaces
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    let locationManager = CLLocationManager()
    let categoryData: [[String]] = [
        ["Default", "Airport", "Amusement Park", "Aquarium", "Art Gallery", "Bowling Alley", "Bakery", "Bar", "Beauty salon", "Bus Station", "Cafe", "Campground", "Car Rental", "Casino", "Lodging", "Movie theater", "Museum", "Night Club", "Park", "Parking", "Restaurant", "Shopping Mall", "Stadium", "Subway Station", "Taxi Stand", "Train Station", "Transit Station", "Travel Agency", "Zoo"]
    ]
    let serverUrlPrefix = "http://localhost:3000/"
    var currentLocation: CLLocation!
    var resultsObject: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keywordTextField.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }

    @IBAction func touchCategory(_ sender: Any) {
        categoryTextField.inputView = UIView()
        McPicker.show(data: categoryData) { [weak self] (selections:[Int: String]) in
            if let name = selections[0] {
                self?.categoryTextField.text = name
            }
        }
    }
    
    @IBAction func autocompleteClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func touchSearch(_ sender: Any) {
        if formValidation() {
            if fromTextField.text != "Your Location" {
                requestPlacesWithoutLocation()
            }
            else {
                requetPlaces(lat: currentLocation.coordinate.latitude, lng: currentLocation.coordinate.longitude)
            }
        }
    }
    
    @IBAction func touchClear(_ sender: Any) {
        keywordTextField.text = ""
        categoryTextField.text = "Default"
        distanceTextField.text = ""
        fromTextField.text = "Your Location"
    }
    
    private func requestPlacesWithoutLocation() {
        let url = URL(string: serverUrlPrefix + "location")
        let parameters: Parameters = ["location": fromTextField.text!]
        
        Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
            self.requetPlaces(lat: response.result.value!["lat"].double!, lng: response.result.value!["lng"].double!)
        }
    }
    
    private func requetPlaces(lat: Double, lng:Double) {
        print(lat, lng)
        let url = URL(string: serverUrlPrefix + "place")
        let category = categoryTextField.text?.lowercased().replacingOccurrences(of: " ", with: "_")
        let distance = distanceTextField.text != "" ? Int(distanceTextField.text!)! : 10
        let parameters: Parameters = ["keyword": keywordTextField.text!,
                                       "category": category!,
                                       "distance": distance,
                                       "lat": lat,
                                       "lng": lng]
        
        Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
            self.resultsObject = response.result.value
            self.performSegue(withIdentifier: "results", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let resultsTableView: ResultsTableViewController = segue.destination as! ResultsTableViewController
        if resultsObject != nil {
            resultsTableView.setTable(resultsObject: resultsObject)
        }
    }
    
    private func formValidation() -> Bool {
        if (keywordTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: 2, dismissOnTap: true)
            return false
        }
        if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: distanceTextField.text!)) {
            self.view.showToast("Distance must be numbers", position: .bottom, popTime: 2, dismissOnTap: true)
            return false
        }
        return true
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keywordTextField.resignFirstResponder()
        return false
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        print("Location \(currentLocation)")
    }
    
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
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

