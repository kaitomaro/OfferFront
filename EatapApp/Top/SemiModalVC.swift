//
//  SemiModalVC.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/21.
//

import UIKit
import FloatingPanel

class SemiModalVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var modalTableView: UITableView!
    var infos: [CustomAnnotaion]?
    var id: Int!

    let s3Url = Configuration.shared.s3Url
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModalCell") as? ModalCell
        cell!.nameLabel.text = infos![indexPath.row].title
        
        let category1 = infos![indexPath.row].category1
        let category2 = infos![indexPath.row].category2

        if category1 != "" && category2 !=  "" {
            cell?.categoryLabel.text = "\(String(describing: category1!))・\(String(describing: category2!))"
        } else if category1 != "" {
            cell?.categoryLabel.text = category1
        } else if category2 != "" {
            cell?.categoryLabel.text = category2
        } else {
            cell?.categoryLabel.text = ""
        }
        cell?.dinnerImageView.layer.cornerRadius = 2
        cell?.lunchImageView.layer.cornerRadius = 2
        if infos![indexPath.row].lunchPrice != nil {
            cell?.lunchPriceLabel.text = infos![indexPath.row].lunchPrice
        } else {
            cell?.lunchPriceLabel.text = ""
        }
        
        if infos![indexPath.row].dinnerPrice != nil {
            cell?.dinnerPriceLabel.text = infos![indexPath.row].dinnerPrice
        } else {
            cell?.dinnerPriceLabel.text = ""
        }
        
        if infos![indexPath.row].imageName != nil {
            cell!.setupCell(url: "\(s3Url)/\(infos![indexPath.row].imageName!)")
        } else {
           print("画像ない")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if infos![indexPath.row].storeId != nil {
            id = infos![indexPath.row].storeId
            UserDefaults.standard.set(id, forKey: "storeId")
            performSegue(withIdentifier: "toStoreVC",sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toStoreVC") {
            let storeVC: StoreViewController = (segue.destination as? StoreViewController)!
            storeVC.id = id
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 480, right: 0)
        modalTableView.delegate = self
        modalTableView.dataSource = self
     }

    func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
}
