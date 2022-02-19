//
//  HistoryCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit
import AlamofireImage

class HistoryCell: UITableViewCell {

    @IBOutlet weak var historyImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var underLineView: UIView!
    
    @IBOutlet weak var discountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(url: String) {
        historyImageView.af.setImage(withURL: URL(string: url)!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
