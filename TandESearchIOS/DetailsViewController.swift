//
//  DetailsViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/21/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON

class DetailsViewController: UITabBarController {

    var placeDetails = [String: JSON]()
    var yelpReviews = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = placeDetails["name"]?.stringValue
        loadYelpReviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDetails(detailsObject: JSON) {
        placeDetails = detailsObject["result"].dictionaryValue
        if isViewLoaded {
            self.title = placeDetails["name"]?.stringValue
        }
    }
    
    func loadYelpReviews() {
        let url = URL(string: Constants.serverUrlPrefix + "yelpreviews")
        let name = placeDetails["name"]?.stringValue
        let address = placeDetails["formatted_address"]?.stringValue
        var location = placeDetails["geometry"]!["location"]
        var city = ""
        var state = ""
        var country = ""
        for addr in (placeDetails["address_components"]?.arrayValue)! {
            if addr["types"].arrayValue.contains("administrative_area_level_2") {
                city = addr["long_name"].stringValue
            }
            if addr["types"].arrayValue.contains("administrative_area_level_1") {
                state = addr["short_name"].stringValue
            }
            if addr["types"].arrayValue.contains("country") {
                country = addr["short_name"].stringValue
            }
        }
        let parameters: Parameters = ["name": name!,
                                      "address1": address!,
                                      "city": city,
                                      "state": state,
                                      "country": country,
                                      "latitude": location["lat"],
                                      "longitude": location["lng"]]
        
        Alamofire.request(url!, parameters: parameters).responseSwiftyJSON { (response) in
            if let reviews = response.result.value {
                 self.yelpReviews = reviews["reviews"].arrayValue
            }
            
        }
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
