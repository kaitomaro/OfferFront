//
//  NormalCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/25.
//

import UIKit

class NormalCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
