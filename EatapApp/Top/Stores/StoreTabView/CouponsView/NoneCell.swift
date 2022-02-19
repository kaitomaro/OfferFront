//
//  NoneCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/06/01.
//

import UIKit

class NoneCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sentenceLabel: UILabel!
    
    func setPosition(collectionView: UICollectionView) {
        self.layer.cornerRadius = 12
        titleLabel.frame = CGRect(x: 5, y: 20, width: collectionView.frame.width - 30, height: 69)
        sentenceLabel.frame = CGRect(x: 5, y: 90, width: collectionView.frame.width - 30, height: 30)
    }
}
