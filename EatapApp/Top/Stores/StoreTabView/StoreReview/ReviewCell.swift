//
//  ReviewCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/01/13.
//

import UIKit
import Cosmos

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var userAgeLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewFrameView: UIView!
    @IBOutlet weak var starButtonView: CosmosView!
    @IBOutlet weak var amountOfStarLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var underLineView: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setPosition() {
        
        
    }
}
