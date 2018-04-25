//
//  ResultTableViewCell.swift
//  TandESearchIOS
//
//  Created by Dongfang Zhao on 4/24/18.
//  Copyright © 2018 zdf. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var favoriteEmptyButton: UIButton!
    @IBOutlet weak var favoriteFilledButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
