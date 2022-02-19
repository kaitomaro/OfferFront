//
//  extensions.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/01/20.
//

import Foundation
import UIKit

extension Notification.Name {
    static let notifyScroll = Notification.Name("scrolled")
    static let notifyApi = Notification.Name("apiShared")
    static let notifyCourseSelected = Notification.Name("courseSelected")
    static let notifyTimeSelected = Notification.Name("timeSelected")
    static let notifyGoReview = Notification.Name("notifyTapped")
    static let notifyCouponSelected = Notification.Name("couponSelected")
    static let notifyMainScroll = Notification.Name("mainScrolled")
}

extension UILabel {
  func lineNumber() -> Int {
    let oneLineRect  =  "a".boundingRect(
      with: self.bounds.size,
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: self.font ?? UIFont()],
      context: nil
    )
    let boundingRect = (self.text ?? "").boundingRect(
      with: self.bounds.size,
      options: .usesLineFragmentOrigin,
      attributes: [NSAttributedString.Key.font: self.font ?? UIFont()],
      context: nil
    )
    return Int(boundingRect.height / oneLineRect.height)
  }
}

extension UITapGestureRecognizer{
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                        // locationOfTouchInLabel.y - textContainerOffset.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
