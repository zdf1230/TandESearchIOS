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

    var twitterButton: UIBarButtonItem!
    var favoriteFilledButton: UIBarButtonItem!
    var favoriteEmptyButton: UIBarButtonItem!
    var placeDetails = [String: JSON]()
    var yelpReviews = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = placeDetails["name"]?.stringValue
        loadYelpReviews()
        
        twitterButton = UIBarButtonItem(image: UIImage(named: "forward-arrow"), style: .plain, target: self, action: #selector(touchTwitterButton))
        favoriteFilledButton = UIBarButtonItem(image: UIImage(named: "favorite-filled"), style: .plain, target: self, action: #selector(touchFavoriteFilledButton))
        favoriteEmptyButton = UIBarButtonItem(image: UIImage(named: "favorite-empty"), style: .plain, target: self, action: #selector(touchFavoriteEmptyButton))
        
        if UserDefaults.standard.value(forKey: (placeDetails["place_id"]?.stringValue)!) != nil {
            navigationItem.setRightBarButtonItems([favoriteFilledButton, twitterButton], animated: true)
        }
        else {
            navigationItem.setRightBarButtonItems([favoriteEmptyButton, twitterButton], animated: true)
        }
        
        
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
    
    @objc func touchTwitterButton() {
        let twitterUrl: String = "https://twitter.com/intent/tweet?text=Check out \((placeDetails["name"]?.stringValue)!) located at \((placeDetails["formatted_address"]?.stringValue)!). Website:&url=\((placeDetails["website"]?.stringValue)!)&hashtags=TravelAndEntertainmentSearch".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        UIApplication.shared.open(URL(string: twitterUrl)!)
    }
    
    @objc func touchFavoriteFilledButton() {
        navigationItem.setRightBarButtonItems([favoriteEmptyButton, twitterButton], animated: true)
        if let placeId = placeDetails["place_id"]?.stringValue {
            UserDefaults.standard.removeObject(forKey: placeId)
            var favoriteList = UserDefaults.standard.array(forKey: "favorite") as! [String]
            if let index = favoriteList.index(of: placeId) {
                favoriteList.remove(at: index)
            }
            UserDefaults.standard.set(favoriteList, forKey: "favorite")
        }
    }
    
    @objc func touchFavoriteEmptyButton() {
        navigationItem.setRightBarButtonItems([favoriteFilledButton, twitterButton], animated: true)
        if let placeId = placeDetails["place_id"]?.stringValue {
            UserDefaults.standard.set(createFavoriteItem(placeDetails: placeDetails), forKey: placeId)
            var favoriteList = UserDefaults.standard.array(forKey: "favorite") as! [String]
            favoriteList.append(placeId)
            UserDefaults.standard.set(favoriteList, forKey: "favorite")
        }
    }
    
    func createFavoriteItem(placeDetails: [String: JSON]) -> [String: String] {
        return ["name": (placeDetails["name"]?.stringValue)!,
                "icon": (placeDetails["icon"]?.stringValue)!,
                "vicinity": (placeDetails["vicinity"]?.stringValue)!,
                "place_id": (placeDetails["place_id"]?.stringValue)!]
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
