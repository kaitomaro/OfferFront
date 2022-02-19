//
//  NoticeCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit
import AlamofireImage


class NoticeCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noticeTitleLabel: UILabel!
    @IBOutlet weak var noticeDetailLabel: UILabel!
    @IBOutlet weak var readDotLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
