//
//  HomePageCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/01/10.
//

import UIKit

class HomePageCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
