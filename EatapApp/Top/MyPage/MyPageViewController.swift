//
//  MyPageViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/19.
//

import UIKit

import SwiftKeychainWrapper
import Alamofire

class MyPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var myPageTableView: UITableView!
    
    private var myPageAlertModel: MyPageNotifyModel?
    let section0Array:[String] = ["お知らせ", "クーポン利用履歴"]
    let section0Image:[UIImage] = [
        UIImage(named: "notice")!,
        UIImage(named: "history")!
    ]
    let section1Array:[String] = ["アカウント設定", "Eatap 利用規約", "お問い合わせ"]
    let section1Image:[UIImage] = [
        UIImage(named: "setting")!,
        UIImage(named: "documents")!,
        UIImage(named: "contact")!
    ]
    let section2Title = "ログアウト"
    let section2Image = UIImage(named: "logout")!
    var api = API()
    let baseUrl = Configuration.shared.apiUrl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        if token != nil && userId != nil {
            loadMyPage()
        } else {
            let alert = UIAlertController(title: "ログイン画面へ", message: "マイページの利用にはログインする必要があります", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                self.tabBarController?.selectedIndex = 0
            })
            
            let logout = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in
                DispatchQueue.main.async {
                    let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotSigned")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                }
            })
            alert.addAction(cancel)
            alert.addAction(logout)
            self.present(alert, animated: true, completion: nil)
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.title = "マイページ"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func loadMyPage(){
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
            if response.response?.statusCode == 401 {
                let alert = UIAlertController(title: "ログイン失敗", message: "ログインし直してください。", preferredStyle: .alert)
                let logout = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    let userId = KeychainWrapper.standard.integer(forKey: "my_id")
                    self.api.logout(params: ["id": String(userId!)]) { (json) in
                        if (json["errors"].exists()){
                            print(json["errors"])
                            return
                        }
                        KeychainWrapper.standard.removeObject(forKey: "token")
                        KeychainWrapper.standard.removeObject(forKey: "my_id")
                        if (KeychainWrapper.standard.string(forKey: "tmp_token") != nil) {
                            KeychainWrapper.standard.removeObject(forKey: "tmp_token")
                        }
                        let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotSigned")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    }
                })
                alert.addAction(logout)
                self.present(alert, animated: true, completion: nil)
            }
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    myPageAlertModel = try decoder.decode(MyPageNotifyModel.self, from: data)
                } catch let error {
                        print("error decode json \(error)")
                }
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
            myPageTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section0Array.count
        } else if section == 1{
            return section1Array.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        }
        else if section == 1 {
            return 50
        }
        return 20
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = myPageTableView.dequeueReusableCell(withIdentifier: "MyPageCell", for: indexPath) as! MyPageCell
            if indexPath.row == 0 {
                if myPageAlertModel?.not_read_mark == 1 {
                    cell.notificationLabel.isHidden = false
                    let viewController = tabBarController?.viewControllers?[2]
                    viewController?.tabBarItem.badgeValue = "●"
                    viewController?.tabBarItem.badgeColor = .clear
                    viewController?.tabBarItem?.setBadgeTextAttributes(
                        [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1), NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 8.0)!], for: .normal
                    )
                } else {
                    cell.notificationLabel.isHidden = true
                    let viewController = tabBarController?.viewControllers?[2]
                    viewController?.tabBarItem.badgeValue = nil
                    viewController?.tabBarItem.badgeColor = .clear
                    viewController?.tabBarItem?.setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
                }
            } else {
                cell.notificationLabel.isHidden = true
            }

            cell.iconImageView.image = section0Image[indexPath.row]
            
            cell.titleLabel.text = section0Array[indexPath.row]
            return cell
        } else if indexPath.section == 1{
            let cell = myPageTableView.dequeueReusableCell(withIdentifier: "MyPageCell", for: indexPath) as! MyPageCell
            cell.notificationLabel.isHidden = true

            cell.iconImageView.image = section1Image[indexPath.row]
            
            cell.titleLabel.text = section1Array[indexPath.row]
            return cell
        } else {
            let cell = myPageTableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath) as! LogoutCell
            cell.logoutLabel.text = section2Title
            cell.logoutIconView.image = section2Image
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        print(indexPath.row)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "toNotice",sender: nil)
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "toHistory",sender: nil)
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "toAccountSetting",sender: nil)
            }
            else if indexPath.row == 1 {
                performSegue(withIdentifier: "toUserPolicy",sender: nil)
            }
            else if indexPath.row == 2 {
                performSegue(withIdentifier: "toContact",sender: nil)
            }
        }
        else if indexPath.section == 2 {
            let alert = UIAlertController(title: "Eatap", message: "ログアウトしますか", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                print("Cancel button tapped")
            })
            let logout = UIAlertAction(title: "ログアウト", style: .default, handler: { (action) -> Void in
                let userId = KeychainWrapper.standard.integer(forKey: "my_id")
                self.api.logout(params: ["id": String(userId!)]) { (json) in
                    if (json["errors"].exists()){
                        print(json["errors"])
                        return
                    }
                    KeychainWrapper.standard.removeObject(forKey: "token")
                    KeychainWrapper.standard.removeObject(forKey: "my_id")
                    if (KeychainWrapper.standard.string(forKey: "tmp_token") != nil) {
                        KeychainWrapper.standard.removeObject(forKey: "tmp_token")
                    }
                    let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "NotSigned")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                }
            })
            alert.addAction(cancel)
            alert.addAction(logout)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toNotice") {
            let accountVC: NoticeViewController = (segue.destination as? NoticeViewController)!
        } else if (segue.identifier == "toHistory") {
            let historyVC: HistoryViewController = (segue.destination as? HistoryViewController)!
        } else if (segue.identifier == "toAccountSetting") {
            let accountVC: AccountSettingViewController = (segue.destination as? AccountSettingViewController)!
        } else if (segue.identifier == "toProfile") {
            let profileVC: ProfileViewController = (segue.destination as? ProfileViewController)!
        } else if (segue.identifier == "toUserPolicy") {
            let profileVC: UserPolicyViewController = (segue.destination as? UserPolicyViewController)!
        } else if (segue.identifier == "toContact") {
            let profileVC: ContactViewController = (segue.destination as? ContactViewController)!
        }
    }
}
