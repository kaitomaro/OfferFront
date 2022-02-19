//
//  FreeDiscountCell.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/31.
//

import UIKit
import AlamofireImage

class FreeDiscountCell: UICollectionViewCell {
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var repeatableLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var coloredView: UIView!
    @IBOutlet weak var couponTitleLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var repeatableLabel2: UILabel!
    
    func setPosition(collectionView: UICollectionView) {
        self.layer.cornerRadius = 12
        coloredView.frame = CGRect(x: 0, y:0, width: self.contentView.frame.width / 2, height: 139)
        let halfWidth = coloredView.frame.width
        menuImageView.frame = CGRect(x: self.contentView.frame.width / 2, y: 0, width: self.contentView.frame.width / 2, height: 139)
        repeatableLabel.frame = CGRect(x: 12, y: 18, width: 70, height: 15)
        repeatableLabel.backgroundColor = .clear
        repeatableLabel.layer.borderWidth = 0.6
        repeatableLabel.layer.cornerRadius = 4
        repeatableLabel.layer.borderColor = UIColor.white.cgColor
        repeatableLabel.textColor = .white
        repeatableLabel.font = UIFont(name: "NotoSansJP-Regular", size: 10)
        
        repeatableLabel2.frame = CGRect(x: 86, y: 18, width: 70, height: 15)
        repeatableLabel2.backgroundColor = .clear
        repeatableLabel2.layer.borderWidth = 0.6
        repeatableLabel2.layer.cornerRadius = 4
        repeatableLabel2.layer.borderColor = UIColor.white.cgColor
        repeatableLabel2.textColor = .white
        repeatableLabel2.font = UIFont(name: "NotoSansJP-Regular", size: 10)
        
        couponTitleLabel.frame = CGRect(x: 18, y: 33, width: halfWidth - 18, height: 26)
        couponTitleLabel.textColor = .white
        couponTitleLabel.font = UIFont(name: "NotoSansJP-Bold", size: 18)
        
        discountPriceLabel.frame = CGRect(x: 18, y:45 , width: halfWidth - 18, height: 66)
        discountPriceLabel.font = UIFont(name: "NotoSansJP-Bold", size: 46)
        discountPriceLabel.textColor = .white
        discountPriceLabel.textAlignment = .left
//        discountLabel1.frame = CGRect(x: 0, y:0 , width: 110, height: 25)
        
        originalPriceLabel.frame = CGRect(x: 19, y: 102, width: halfWidth - 18, height: 26)
        originalPriceLabel.textColor = .white
        originalPriceLabel.textAlignment = .left
        originalPriceLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        
        drawDashedLine(halfWidth: halfWidth,color: .white, lineWidth: 3, lineSize: 26, spaceSize: 12, view: self.contentView)
    }
    
    func drawDashedLine(halfWidth: CGFloat,color: UIColor, lineWidth: CGFloat, lineSize: NSNumber, spaceSize: NSNumber, view: UIView) {
        let dashedLineLayer: CAShapeLayer = CAShapeLayer()
        dashedLineLayer.frame = self.bounds
        dashedLineLayer.strokeColor = color.cgColor
        dashedLineLayer.lineWidth = lineWidth
        dashedLineLayer.lineDashPattern = [lineSize, spaceSize]
        let path: CGMutablePath = CGMutablePath()
        path.move(to: CGPoint(x: halfWidth - 0.5, y: 0.0))
        path.addLine(to: CGPoint(x: halfWidth - 0.5, y: self.frame.size.height))
        dashedLineLayer.path = path
        view.layer.addSublayer(dashedLineLayer)
    }
    
    func setupCell(url: String) {
        menuImageView.af.setImage(withURL: URL(string: url)!)
    }
}
