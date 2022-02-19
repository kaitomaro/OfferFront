//
//  IntroductionCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/01/10.
//

import UIKit

class IntroductionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
