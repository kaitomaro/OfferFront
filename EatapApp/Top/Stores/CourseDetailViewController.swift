//
//  CourseDetailViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/29.
//

import UIKit

class CourseDetailViewController: UIViewController {
    
    var menu: MenuModel?
    var store: String?
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var coursePriceLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if store != nil {
            self.navigationItem.title = store!
        }
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        if  menu != nil {
            courseNameLabel.text = menu!.name
            let price = String(menu!.price!)
            let text = "価格：￥\(price)"
            coursePriceLabel.text = text
            
            let titleRange = (text as NSString).range(of: "価格：￥")
            let priceRange = (text as NSString).range(of: price)
            let attributedPrice = NSMutableAttributedString(string: text)
            attributedPrice.addAttributes(
                [
                    NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 16)!
                ], range: titleRange
            )
            attributedPrice.addAttributes(
                [
                    NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Bold", size: 16)!
                ], range: priceRange
            )
            coursePriceLabel.attributedText = attributedPrice
            
            detailTextView.text = menu?.detail
        }
    }
}
