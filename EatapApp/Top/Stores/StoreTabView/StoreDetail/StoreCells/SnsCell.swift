//
//  SnsCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/01/10.
//

import UIKit

class SnsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var snsLinkTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
