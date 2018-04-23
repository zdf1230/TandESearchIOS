//
//  ReviewsTableViewCell.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/22/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit
import Cosmos

class ReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewPhoto: UIImageView!
    @IBOutlet weak var author_name: UILabel!
    @IBOutlet weak var reviewTime: UILabel!
    @IBOutlet weak var reviewRating: CosmosView!
    @IBOutlet weak var reviewText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
