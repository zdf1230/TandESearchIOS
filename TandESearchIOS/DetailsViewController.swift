//
//  DetailsViewController.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/21/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailsViewController: UITabBarController {

    var placeDetails = [String: JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = placeDetails["name"]?.stringValue
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
