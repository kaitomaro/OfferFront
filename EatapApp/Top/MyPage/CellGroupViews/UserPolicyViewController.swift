//
//  UserPolicyViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit

class UserPolicyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var policyTableView: UITableView!
    var policies:[String] = ["利用規約", "プライバシーポリシー"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "規約・プライバシーポリシー"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = policyTableView.dequeueReusableCell(withIdentifier: "policyCell", for: indexPath)
        cell.textLabel?.text = policies[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("利用規約が選ばれました")
            performSegue(withIdentifier: "toKiyaku", sender: nil)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: "toPolicy", sender: nil)
            print("プライバシーポリシーが選ばれました")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toKiyaku" {
            let kiyakuVC: KiyakuVC = (segue.destination as? KiyakuVC)!
        } else if segue.identifier == "toPolicy"{
            let policyVC: PolicyVC = (segue.destination as? PolicyVC)!
        }
    }
}
