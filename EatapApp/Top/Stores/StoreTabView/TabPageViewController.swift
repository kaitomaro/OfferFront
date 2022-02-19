//
//  CategoryScrollContentsViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/01/07.
//

import UIKit
import XLPagerTabStrip

class TabPageViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarItemFont = UIFont(name: "NotoSansJP-Medium", size: 14)!
        settings.style.buttonBarItemTitleColor = #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 1)
        settings.style.buttonBarLeftContentInset = 5
        settings.style.buttonBarRightContentInset = 5
        settings.style.buttonBarHeight = 30

        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(self.changeTime),name: .notifyTimeSelected ,object: nil)

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else {
                return
            }
            oldCell?.label.textColor = #colorLiteral(red: 0.2235294118, green: 0.2235294118, blue: 0.2235294118, alpha: 1)
            newCell?.label.textColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
        }
    }
    
    

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "First")
        let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Second")
        let thirdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Third")
        let fourthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Fourth")
        let childViewControllers:[UIViewController] = [firstVC, secondVC, thirdVC, fourthVC]
        return childViewControllers
    }
    
    @objc func changeTime() {
        moveToViewController(at: 0, animated: false)
        buttonBarView.reloadData()
    }
}
