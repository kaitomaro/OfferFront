//
//  ModalCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/21.
//

import UIKit
import AlamofireImage


class ModalCell: UITableViewCell {

    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var lunchImageView: UIImageView!
    @IBOutlet weak var dinnerImageView: UIImageView!
    @IBOutlet weak var lunchPriceLabel: UILabel!
    @IBOutlet weak var dinnerPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(url: String) {
        storeImageView.af.setImage(withURL: URL(string: url)!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
