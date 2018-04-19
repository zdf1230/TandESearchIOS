//
//  ViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/17/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import McPicker
import GooglePlaces

class ViewController: UIViewController {

    let categoryData: [[String]] = [
        ["Default", "Airport", "Amusement Park", "Aquarium", "Art Gallery", "Bowling Alley", "Bakery", "Bar", "Beauty salon", "Bus Station", "Cafe", "Campground", "Car Rental", "Casino", "Lodging", "Movie theater", "Museum", "Night Club", "Park", "Parking", "Restaurant", "Shopping Mall", "Stadium", "Subway Station", "Taxi Stand", "Train Station", "Transit Station", "Travel Agency", "Zoo"]
    ]
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

