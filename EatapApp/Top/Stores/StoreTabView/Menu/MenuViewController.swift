//
//  MenuViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/25.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftKeychainWrapper


class MenuViewController: UIViewController,IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate {
    
    @IBOutlet weak var segmentControl: MenuSegmentControl!
    private var menuModel: [MenuModel]?
    let api = API()
    var id: Int?
    private var foodMenu: [MenuModel]?
    private var drinkMenu: [MenuModel]?
    private var courseMenu: [MenuModel]?
    private var lunchMenu: [MenuModel]?
    @IBOutlet weak var menuTableView: UITableView!
    let baseUrl = Configuration.shared.apiUrl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.delegate = self
        menuTableView.alwaysBounceHorizontal = false
        

        NotificationCenter.default.addObserver(self,selector: #selector(self.feedScrollMove),name: .notifyMainScroll ,object: nil)
        menuTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 400, right: 0)
        id = UserDefaults.standard.integer(forKey: "storeId")
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if UserDefaults.standard.integer(forKey: "childscroll") == 1 {
            menuTableView.isScrollEnabled = true
        } else {
            menuTableView.isScrollEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menuModel != nil {
            let segmentIndex = segmentControl.selectedSegmentIndex
            switch segmentIndex {
            case 0 :
                return courseMenu!.count
            case 1 :
                return foodMenu!.count
            case 2 :
                return drinkMenu!.count
            case 3 :
                return lunchMenu!.count
            default:
                return 0
            }
        }
        return 0
    }
    
    @objc func feedScrollMove(notification: NSNotification) {
        let posisionY:CGFloat = notification.userInfo?["offsety"] as? CGFloat ?? 0
        menuTableView.isScrollEnabled = true
        menuTableView.contentOffset.y = posisionY - 310
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let segmentIndex = segmentControl.selectedSegmentIndex
        switch segmentIndex {
        case 0 :
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "MenuNormalCell") as? NormalCell
            if courseMenu != nil {
                cell?.nameLabel.text = courseMenu![indexPath.row].name
                cell?.priceLabel.text = "￥\(courseMenu![indexPath.row].price!)"
            }
            return cell!
        case 1 :
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "MenuNormalCell") as? NormalCell
            if foodMenu != nil {
                cell?.nameLabel.text = foodMenu![indexPath.row].name
                cell?.priceLabel.text = "￥\(foodMenu![indexPath.row].price!)"
            }
            return cell!
        case 2 :
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "MenuNormalCell") as? NormalCell
            if drinkMenu != nil {
                cell?.nameLabel.text = drinkMenu![indexPath.row].name
                cell?.priceLabel.text = "￥\(drinkMenu![indexPath.row].price!)"
            }
            return cell!
        case 3 :
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "MenuNormalCell") as? NormalCell
            if lunchMenu != nil {
                cell?.nameLabel.text = lunchMenu![indexPath.row].name
                cell?.priceLabel.text = "￥\(lunchMenu![indexPath.row].price!)"
            }
            return cell!
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let segmentIndex = segmentControl.selectedSegmentIndex
        switch segmentIndex {
        case 0 :
            if courseMenu != nil {
                let selectedInfo:[String: Any] = ["MenuData": courseMenu![indexPath.row]]
                NotificationCenter.default.post(name: .notifyCourseSelected, object: nil,userInfo: selectedInfo)
            }
        default:
            return
        }
    }
    var itemInfo: IndicatorInfo = "メニュー"
    let semaphore = DispatchSemaphore(value: 1)
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func loadData() {
        let searchUrl = "\(baseUrl)/shop/menu/\(String(id!))"
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
                print(data)
                do {
                    menuModel = try JSONDecoder().decode([MenuModel].self, from: data)
                } catch let error {
                    print("error decode json \(error)")
                }
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
            drinkMenu = menuModel?.filter{
                $0.menu_type == 1
            }
            foodMenu = menuModel?.filter{
                $0.menu_type == 2
            }
            courseMenu = menuModel?.filter{
                $0.menu_type == 3
            }
            lunchMenu = menuModel?.filter{
                $0.menu_type == 4
            }
            menuTableView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == menuTableView {
            var userInfo: [String: Any] = [
                "offsety": scrollView.contentOffset.y
            ]
            
            if scrollView.contentOffset.y <= 0 {
                print(scrollView.contentOffset)
                if scrollView.contentOffset.y < -310 {
                    scrollView.contentOffset.y = -310
                    userInfo["offsety"] = -310
                }
                
                NotificationCenter.default.post(name: .notifyScroll, object: nil,userInfo:userInfo)
                menuTableView.isScrollEnabled = false
                UserDefaults.standard.setValue(0 , forKey: "childscroll")
            }
        }
    }
    
    @IBAction func selectedSegment(_ sender: Any) {
        menuTableView.reloadData()
    }
}

