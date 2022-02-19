//
//  NoticeDetailVC.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/06/22.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class NoticeDetailVC: UIViewController {
    
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var notice: NoticeModel?
    var api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "お知らせ", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = "お知らせ"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        sendRead()
        titleLabel.text = notice?.title
        bodyTextView.text = notice?.body!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let inDate:NSDate = dateFormatter.date(from: notice!.created_at)! as NSDate
        
        let outDateFormatter = DateFormatter()
        outDateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        print(outDateFormatter.string(from: inDate as Date))
        timeLabel.text = outDateFormatter.string(from: inDate as Date)
    }
    
    func sendRead() {
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let id = notice?.id
        api.readArticle(params: [
            "user_id": String(userId!),
            "notice_id": String(id!)
        ]) { (json) in
            print(json)
        }
    }
}
