//
//  DiscountCollectionViewCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2020/12/27.
//

import UIKit


class DiscountCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var selectedView: UIView!
    
    func setTimeLabel(text: String) {
        timeLabel.text = text
    }
    
    private func activationSelfSizing() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
}
