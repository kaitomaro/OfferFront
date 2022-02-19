//
//  NoticeViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class NoticeViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var noticeTableView: UITableView!
    
    @IBOutlet weak var networkTimeView: UIView!
    private var noticeModel:[NoticeModel]?
    private var selected: NoticeModel?
    let baseUrl = Configuration.shared.apiUrl
    var readButtonItem: UIBarButtonItem!
    var api = API()
    var activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noticeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 250, right: 0)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        readButtonItem = UIBarButtonItem(title: "全て既読", style: .done, target: self, action:  #selector(readButtonTapped(_:)))
        readButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 14.0)!], for: .normal)
        readButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 14.0)!], for: .disabled)
        readButtonItem.tintColor = #colorLiteral(red: 0.1450980392, green: 0.4274509804, blue: 0.9568627451, alpha: 1)
        self.navigationItem.rightBarButtonItem = readButtonItem
        
        activityIndicatorView.style = .large
        activityIndicatorView.center = view.center
        activityIndicatorView.color = .black
        self.networkTimeView.addSubview(activityIndicatorView)

    }
    
    @objc func readButtonTapped(_ sender: UIBarButtonItem) {
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        networkTimeView.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.readButtonItem.isEnabled = false
        api.readAll(params: ["user_id": String(userId!)])
        { [self] (json) in
            if (json["errors"].exists()){
                print("we have some errors")
                self.activityIndicatorView.stopAnimating()
                return
            }
            self.loadNotices()
            self.readButtonItem.isEnabled = true
            self.activityIndicatorView.stopAnimating()
            networkTimeView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        loadNotices()
        self.navigationItem.title = "お知らせ"
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noticeModel != nil {
            if noticeModel!.count > 0 {
                return noticeModel!.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = noticeTableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as! NoticeCell
        if ((noticeModel?[indexPath.row]) != nil) {
            cell.noticeTitleLabel.text = noticeModel![indexPath.row].title
            cell.noticeDetailLabel.text = noticeModel![indexPath.row].body
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let inDate:NSDate = dateFormatter.date(from: noticeModel![indexPath.row].created_at)! as NSDate
            
            let outDateFormatter = DateFormatter()
            outDateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
            print(outDateFormatter.string(from: inDate as Date))
            
            cell.timeLabel.text = outDateFormatter.string(from: inDate as Date)
            
            if noticeModel?[indexPath.row].marks_id == nil {
                cell.readDotLabel.isHidden = false
                cell.noticeTitleLabel.font = UIFont(name: "NotoSansJP-Bold", size: 20.0)
                cell.noticeDetailLabel.font = UIFont(name: "NotoSansJP-Bold", size: 10.0)
            } else {
                cell.readDotLabel.isHidden = true
                cell.noticeTitleLabel.font = UIFont(name: "NotoSansJP-Regular", size: 20.0)
                cell.noticeDetailLabel.font = UIFont(name: "NotoSansJP-Regular", size: 10.0)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = noticeModel?[indexPath.row]
        performSegue(withIdentifier: "toNoticeDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toNoticeDetail") {
            let vc: NoticeDetailVC = (segue.destination as? NoticeDetailVC)!
            vc.notice = selected
        }
    }
    
    func loadNotices() {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let searchUrl = "\(baseUrl)/notice/\(String(userId!))"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        
        AF.request(
            searchUrl,
            method: .get,
            parameters: ["":""],
            encoding: URLEncoding(destination: .queryString),
            headers: headers)
            .responseJSON { [self] response in
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                do {
                    self.noticeModel = try JSONDecoder().decode([NoticeModel].self, from: data)  
                } catch let error {
                    print("error decode json \(error)")
                }
                print(response.result)
                noticeTableView.reloadData()
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
        }
    }
    
    
}
