//
//  ReviewModel.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/23/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReviewModel {
    
    var name: String
    var url: String
    var photoUrl: String
    var text: String
    var rating: Double
    var time: String
    var num: Int
    
    init(index: Int, review: JSON, isYelp: Bool) {
        
        if isYelp {
            self.num = index
            self.name = review["user"]["name"].stringValue
            self.url = review["url"].stringValue
            self.photoUrl = review["user"]["image_url"].stringValue
            if self.photoUrl == "" {
                self.photoUrl = Constants.yelpDefaultAvatarUrl
            }
            self.text = review["text"].stringValue
            self.rating = review["rating"].doubleValue
            self.time = review["time_created"].stringValue
        }
        else {
            self.num = index
            self.name = review["author_name"].stringValue
            self.url = review["author_url"].stringValue
            if self.url == "" {
                self.url =  Constants.googleDefaultUrl
            }
            self.photoUrl = review["profile_photo_url"].stringValue
            if self.photoUrl == "" {
                self.photoUrl = Constants.googleDefaultAvatarUrl
            }
            self.text = review["text"].stringValue
            self.rating = review["rating"].doubleValue
            
            let timeDate = Date(timeIntervalSince1970: TimeInterval(review["time"].intValue))
            let timeDateFormatter = DateFormatter()
            timeDateFormatter.dateFormat = "y-MM-dd H:mm:ss"
            self.time = timeDateFormatter.string(from: timeDate)
        }
    }
    
    
}
