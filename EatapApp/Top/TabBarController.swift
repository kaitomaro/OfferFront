//
//  TabBarController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/08/31.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper


class TabBarController: UITabBarController {
    
    let baseUrl = Configuration.shared.apiUrl
    private var navAlertModel: NavAlertModel?


    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.shadowRadius = 3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -3.0)
        tabBar.layer.masksToBounds = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes =
                    [NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!]
        UITabBarItem.appearance().setTitleTextAttributes( [ .font : UIFont.init(name: "NotoSansJP-Regular", size: 8)!, .foregroundColor : #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)], for: .normal)
        UITabBar.appearance().unselectedItemTintColor = #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
        UITabBarItem.appearance().setTitleTextAttributes( [ .font : UIFont.init(name: "NotoSansJP-Regular", size: 8)!, .foregroundColor : #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)], for: .selected)
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")

        if token != nil && userId != nil {
            loadAlertInfo()
        } else {
            let tabBarItem = self.viewControllers?[1].tabBarItem
            tabBarItem?.badgeValue = nil
            tabBarItem?.badgeColor = .clear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        tabBar.isHidden = false
    }
    
    func loadAlertInfo(){
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let searchUrl = "\(baseUrl)/my_page/\(String(userId!))"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(
            searchUrl,
            method: .get,
            parameters: ["": ""],
            encoding: URLEncoding(destination: .queryString),
            headers: headers).responseJSON{ [self] response in
                switch response.result {
                case .success:
                    guard let data = response.data else { return }
                    do {
                        let decoder = JSONDecoder()
                        navAlertModel = try decoder.decode(NavAlertModel.self, from: data)
                    } catch let error {
                            print("error decode json \(error)")
                    }
                case .failure(let error):
                    print("RESPONSE ERROR：", error)
                }
                if navAlertModel?.have_loto == 0 {
                    let tabBarItem = self.viewControllers?[1].tabBarItem
                    tabBarItem?.badgeValue = nil
                    tabBarItem?.badgeColor = .clear
                } else {
                    let tabBarItem = self.viewControllers?[1].tabBarItem
                    tabBarItem?.badgeValue = "●"
                    tabBarItem?.badgeColor = .clear
                    tabBarItem?.setBadgeTextAttributes(
                        [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1), NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 8.0)!], for: .normal
                    )
                }
                
                if navAlertModel?.not_read_mark == 0 {
                    let viewController = self.viewControllers?[2]
                    viewController?.tabBarItem.badgeValue = nil
                    viewController?.tabBarItem.badgeColor = .clear
                } else {
                    let tabBarItem = self.viewControllers?[2].tabBarItem
                    tabBarItem?.badgeValue = "●"
                    tabBarItem?.badgeColor = .clear
                    tabBarItem?.setBadgeTextAttributes(
                        [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1), NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 8.0)!], for: .normal
                    )
                }
        }
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
