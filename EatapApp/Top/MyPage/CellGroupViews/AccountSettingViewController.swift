//
//  AccountSettingViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit

class AccountSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var accountTableView: UITableView!
    var elements = ["プロフィール編集", "パスワード変更"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "アカウント設定"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell")!
        cell.textLabel?.text = elements[indexPath.row]
        cell.textLabel?.font = UIFont(name: "HiraginoSans-W3", size: 15)!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "toProfile",sender: nil)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: "toChangePass", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            let storeVC: ProfileViewController = (segue.destination as? ProfileViewController)!
        } else if (segue.identifier == "toChangePass") {
            let storeVC: ChangePassViewController = (segue.destination as? ChangePassViewController)!
        }
    }
}
