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
import SwiftSpinner

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mainSelectedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var favoriteTableView: UITableView!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    let locationManager = CLLocationManager()
    let categoryData: [[String]] = [
        ["Default", "Airport", "Amusement Park", "Aquarium", "Art Gallery", "Bowling Alley", "Bakery", "Bar", "Beauty salon", "Bus Station", "Cafe", "Campground", "Car Rental", "Casino", "Lodging", "Movie theater", "Museum", "Night Club", "Park", "Parking", "Restaurant", "Shopping Mall", "Stadium", "Subway Station", "Taxi Stand", "Train Station", "Transit Station", "Travel Agency", "Zoo"]
    ]
    var currentLocation: CLLocation!
    var resultsObject: JSON!
    var detailsObject: JSON!
    var favoriteList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = true
        
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        
        keywordTextField.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        if UserDefaults.standard.array(forKey: "favorite") == nil {
            UserDefaults.standard.set([String](), forKey: "favorite")
        }
        else {
            favoriteList = UserDefaults.standard.array(forKey: "favorite") as! [String]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.array(forKey: "favorite") == nil {
            UserDefaults.standard.set([String](), forKey: "favorite")
        }
        else {
            favoriteList = UserDefaults.standard.array(forKey: "favorite") as! [String]
        }
        favoriteTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }

    @IBAction func mainSelectedChanged(_ sender: Any) {
        switch mainSelectedSegmentedControl.selectedSegmentIndex {
        case 0:
            favoriteTableView.isHidden = true
            searchView.isHidden = false
        case 1:
            favoriteTableView.isHidden = false
            searchView.isHidden = true
            keywordTextField.resignFirstResponder()
            distanceTextField.resignFirstResponder()
        default:
            break
        }
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
            keywordTextField.resignFirstResponder()
            distanceTextField.resignFirstResponder()
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
        keywordTextField.resignFirstResponder()
        distanceTextField.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (favoriteList.isEmpty) {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Favorites"
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        return favoriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteItem", for: indexPath)
        
        let placeId = favoriteList[indexPath.row]
        let place = UserDefaults.standard.dictionary(forKey: placeId) as! [String: String]
        cell.textLabel?.text = place["name"]
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = place["vicinity"]
        cell.detailTextLabel?.numberOfLines = 0
        let icon = try! Data(contentsOf: URL(string: place["icon"]!)!)
        cell.imageView?.image = UIImage(data: icon, scale: CGFloat(1.5))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            favoriteTableView.beginUpdates()
            let placeId = favoriteList[indexPath.row]
            let place = UserDefaults.standard.dictionary(forKey: placeId) as! [String: String]
            let name = place["name"]!
            UserDefaults.standard.removeObject(forKey: placeId)
            if let index = favoriteList.index(of: placeId) {
                favoriteList.remove(at: index)
            }
            UserDefaults.standard.set(favoriteList, forKey: "favorite")
            favoriteTableView.deleteRows(at: [indexPath], with: .fade)
            favoriteTableView.endUpdates()
            
            self.view.showToast("\(name) was removed from favorites", position: .bottom, popTime: 2, dismissOnTap: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftSpinner.show("Fetching place details...")
        let placeId = favoriteList[indexPath.row]
        let url = URL(string: Constants.serverUrlPrefix + "placedetails")
        let parameters: Parameters = ["placeid": placeId]
        
        Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
            self.detailsObject = response.result.value
            SwiftSpinner.hide()
            self.performSegue(withIdentifier: "favoriteDetails", sender: nil)
        }
    }
    
    private func requestPlacesWithoutLocation() {
        let url = URL(string: Constants.serverUrlPrefix + "location")
        let parameters: Parameters = ["location": fromTextField.text!]
        
        Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
            self.requetPlaces(lat: response.result.value!["lat"].double!, lng: response.result.value!["lng"].double!)
        }
    }
    
    private func requetPlaces(lat: Double, lng:Double) {
        SwiftSpinner.show("Searching...")
        let url = URL(string: Constants.serverUrlPrefix + "place")
        let category = categoryTextField.text?.lowercased().replacingOccurrences(of: " ", with: "_")
        let distance = distanceTextField.text != "" ? Int(distanceTextField.text!)! : 10
        let parameters: Parameters = ["keyword": keywordTextField.text!,
                                       "category": category!,
                                       "distance": distance,
                                       "lat": lat,
                                       "lng": lng]
        
        Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
            self.resultsObject = response.result.value
            SwiftSpinner.hide()
            self.performSegue(withIdentifier: "results", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "results" {
            let resultsTableView: ResultsTableViewController = segue.destination as! ResultsTableViewController
            if resultsObject != nil {
                resultsTableView.setTable(resultsObject: resultsObject)
            }
        }
        if segue.identifier == "favoriteDetails" {
            let detailsView: DetailsViewController = segue.destination as! DetailsViewController
            if detailsObject != nil {
                detailsView.setDetails(detailsObject: detailsObject)
            }
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

