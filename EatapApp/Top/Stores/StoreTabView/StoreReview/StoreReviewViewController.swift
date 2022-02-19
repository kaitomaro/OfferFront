//
//  StoreReviewViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2020/12/29.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftKeychainWrapper


class StoreReviewViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    @IBOutlet weak var reviewTableView: UITableView!
    
    var itemInfo: IndicatorInfo = "レビュー"
    var userInfo: [String: Any] = [
        "offsety": CGFloat(),
        "state": 0
    ]
    var id:Int?
    private var reviewModel: [ReviewModel]?
    let dateFormatter = DateFormatter()
    let today = Date()

    let baseUrl = Configuration.shared.apiUrl
    let userId = KeychainWrapper.standard.integer(forKey: "my_id")
    let token = KeychainWrapper.standard.string(forKey: "token")
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTableView.delegate = self
        NotificationCenter.default.addObserver(self,selector: #selector(self.feedScrollMove),name: .notifyMainScroll ,object: nil)
        id = UserDefaults.standard.integer(forKey: "storeId")
        reviewTableView.dataSource = self
        reviewTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 400, right: 0)
        reviewTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if UserDefaults.standard.integer(forKey: "childscroll") == 1 {
            reviewTableView.isScrollEnabled = true
        } else {
            reviewTableView.isScrollEnabled = false
        }
        loadReview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    func loadReview() {
        
        let searchUrl = "\(baseUrl)/review/\(String(id!))"
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        AF.request(
            searchUrl,
            method: .get,
            parameters: nil,
            encoding: URLEncoding(destination: .queryString),
            headers: headers
        ).responseJSON { [self] response in
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                do {
                    reviewModel = try JSONDecoder().decode([ReviewModel].self, from: data)
                } catch let error {
                    print("error decode json \(error)")
                }
                reviewTableView.reloadData()
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if reviewModel != nil {
                if reviewModel!.count >= 1 {
                    return reviewModel!.count
                }
                return 0
            } else {
                return 0
            }
        }
    }
    
    @objc private func didTapCreateReviewButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: .notifyGoReview, object: nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewButtonCell") as? ReviewButtonCell
            cell?.createReviewButton.layer.cornerRadius = 23
            if userId != nil && token != nil {
                cell?.createReviewButton.isHidden = false
                cell?.createReviewButton.isUserInteractionEnabled = true
            } else {
                cell?.createReviewButton.isHidden = true
                cell?.createReviewButton.isUserInteractionEnabled = false
            }
            cell?.createReviewButton.addTarget(self, action: #selector(didTapCreateReviewButton(_:)), for: .touchUpInside)
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell") as! ReviewCell
            if reviewModel != nil {
                if reviewModel?[indexPath.row] != nil {
                    cell.reviewLabel.text = reviewModel![indexPath.row].sentence
                    cell.starButtonView.rating = reviewModel![indexPath.row].rate!
                    cell.amountOfStarLabel.text = String(reviewModel![indexPath.row].rate!)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let inDate:NSDate = dateFormatter.date(from: reviewModel![indexPath.row].created_at!)! as NSDate
                    let outDateFormatter = DateFormatter()
                    outDateFormatter.dateFormat = "yyyy年MM月dd日"
                    print(outDateFormatter.string(from: inDate as Date))
                    cell.dateLabel.text = outDateFormatter.string(from: inDate as Date)
                    cell.userAgeLabel.text = "\(reviewModel![indexPath.row].name)"
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == reviewTableView {
            var userInfo: [String: Any] = [
                "offsety": scrollView.contentOffset.y
            ]
            
            if scrollView.contentOffset.y <= 0 {
                print(scrollView.contentOffset)
                if scrollView.contentOffset.y < -310 {
                    scrollView.contentOffset.y = -310
                    userInfo["offsety"] = -310
                }
                reviewTableView.isScrollEnabled = false
                NotificationCenter.default.post(name: .notifyScroll, object: nil,userInfo:userInfo)
                UserDefaults.standard.setValue(0 , forKey: "childscroll")
            }
        }
    }
    
    @objc func feedScrollMove(notification: NSNotification) {
        let posisionY:CGFloat = notification.userInfo?["offsety"] as? CGFloat ?? 0
        print(posisionY)
        reviewTableView.isScrollEnabled = true
        reviewTableView.contentOffset.y = posisionY - 310
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
