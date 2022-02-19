//
//  TopPhotoCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/22.
//

import UIKit
import AlamofireImage

class TopPhotoCell: UICollectionViewCell {
    @IBOutlet weak var topImageView: UIImageView!
    func setupCell(url: String) {
        topImageView.af.setImage(withURL: URL(string: url)!)
    }
}
