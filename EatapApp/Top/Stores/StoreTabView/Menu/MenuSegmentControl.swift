//
//  MenuSegmentControl.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/09/11.
//

import UIKit

class MenuSegmentControl: UISegmentedControl {
    override func layoutSubviews(){
        super.layoutSubviews()
        
        selectedSegmentTintColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
        
        setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "NotoSansJP-Medium", size: 14.0)!,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
            ], for: .normal
        )
      
        setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "NotoSansJP-Bold", size: 14.0)!,NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)], for: .selected)
        
        layer.masksToBounds = true

        frame.size.height = 30
        backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        let cornerRadius = 15

        let maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        clipsToBounds = true
        layer.cornerRadius = CGFloat(cornerRadius)

        layer.maskedCorners = maskedCorners
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
            foregroundImageView.image = UIImage()
            foregroundImageView.clipsToBounds = true
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            foregroundImageView.layer.cornerRadius = 18
            foregroundImageView.layer.maskedCorners = maskedCorners
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}
