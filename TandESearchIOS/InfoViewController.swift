//
//  InfoViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/21/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import SwiftyJSON
import Cosmos

class InfoViewController: UIViewController {

    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var phoneNumberTextView: UITextView!
    @IBOutlet weak var priceLevelLabel: UILabel!
    @IBOutlet weak var websiteTextView: UITextView!
    @IBOutlet weak var googlePageTextView: UITextView!
    @IBOutlet weak var ratingView: CosmosView!
    var placeDetails = [String: JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placeDetails = (tabBarController as! DetailsViewController).placeDetails
        AddressLabel.text = placeDetails["formatted_address"]?.stringValue
        phoneNumberTextView.text = placeDetails["international_phone_number"]?.stringValue
        if let dollerCount = placeDetails["price_level"]?.intValue {
            var str = ""
            for _ in 1...dollerCount {
                str += "$"
            }
            priceLevelLabel.text = str
        }
        websiteTextView.text = placeDetails["website"]?.stringValue
        googlePageTextView.text = placeDetails["url"]?.stringValue
        if let rating = placeDetails["rating"]?.doubleValue {
            ratingView.rating = rating
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
