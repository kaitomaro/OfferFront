//
//  HistoryViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var historyTableView: UITableView!
    
    private var historyModel: [HistoryModel]?
    let s3Url = Configuration.shared.s3Url
    let baseUrl = Configuration.shared.apiUrl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 250, right: 0)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        loadHistory()
        self.navigationItem.title = "クーポン利用履歴"
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historyModel != nil {
            if historyModel!.count > 0 {
                return 1
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if historyModel != nil {
            if historyModel!.count > 0 {
                return historyModel!.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
        cell.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        let name = historyModel?[indexPath.section].name
        let created_at = historyModel?[indexPath.section].created_at
        let discount = historyModel?[indexPath.section].discount
        let discount_type = historyModel?[indexPath.section].discount_type
        let service_type = historyModel?[indexPath.section].service_type
        let people = historyModel?[indexPath.section].people
        let top_image = historyModel?[indexPath.section].top_image
        let menu_name = historyModel?[indexPath.section].menu_name
        
        if top_image != nil {
            cell.setupCell(url: "\(s3Url)/\(top_image!)")
        }
        
        if name != nil {
            cell.nameLabel.text = name!
        }
        
        if people != nil {
            let people = "\(String(people!))人"
            let peopleTxt = "人数：\(people)"
            cell.peopleLabel.text = peopleTxt
            cell.peopleLabel.attributedText = setPeopleLabel(text: peopleTxt, people: people)
        }
        
        if created_at != nil {
            cell.dayLabel.attributedText = setDayLabel(created_at: created_at!)
        }
        
        if menu_name != nil && discount != nil && discount_type != nil && service_type != nil {
            
            cell.discountLabel.attributedText = setDiscountLabel(menu_name: menu_name!, discount_type: discount_type!, service_type: service_type!, discount: -discount!)
        }
        return cell
    }
    
    private func setPeopleLabel(text: String, people: String) ->NSMutableAttributedString {
        let titleRange = (text as NSString).range(of: "人数：")
        let ninRange = (text as NSString).range(of: people)
        let attributedPeople = NSMutableAttributedString(string: text)
        attributedPeople.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Bold", size: 14.0)!
            ], range: ninRange
        )
        attributedPeople.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 14)!
            ], range: titleRange
        )
        return attributedPeople
    }
    
    private func setDayLabel(created_at: String) ->NSMutableAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let inDate:NSDate = dateFormatter.date(from: created_at)! as NSDate
        let outDateFormatter = DateFormatter()
        outDateFormatter.dateFormat = "MM月dd日 HH:mm"
        let day = outDateFormatter.string(from: inDate as Date)
        let text = "日時：\(day)"
        let titleRange = (text as NSString).range(of: "日時：")
        let dayRange = (text as NSString).range(of: day)
        let attributedPeople = NSMutableAttributedString(string: text)
        attributedPeople.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Bold", size: 14.0)!
            ], range: dayRange
        )
        attributedPeople.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 14)!
            ], range: titleRange
        )
        return attributedPeople
    }
    
    private func setDiscountLabel(menu_name: String, discount_type: Int, service_type: Int, discount:Int) ->NSMutableAttributedString {
        var labelTxt: String!
        var discountAmount: String!
        var unitStr: String!
        
        if service_type == 1 {
            labelTxt = "\(menu_name)無料"
            discountAmount = "無料"
            unitStr = ""
        } else if service_type != 1 && discount_type == 1 {
            labelTxt = "\(menu_name) \(String(describing: discount))%"
            discountAmount = "\(String(describing: discount))"
            unitStr = "%"
        } else if service_type != 1 && discount_type == 0 {
            labelTxt = "\(menu_name) \(String(describing: discount))円"
            discountAmount = "\(String(describing: discount))"
            unitStr = "円"
        }
        
        var textColor: UIColor?
        print(discount_type)
        print(discount)
        if discount_type == 0 {
            if discount <= -500 {
                textColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
            } else if discount <= -50 {
                textColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
            } else {
                textColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
            }
        } else {
            if discount <= -15  {
                textColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
            } else if discount <= -10 {
                textColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
            } else {
                textColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
            }
        }
        
        let menuRange = (labelTxt as NSString).range(of: menu_name)
        let discountRange = (labelTxt as NSString).range(of: discountAmount)
        let unitRange = (labelTxt as NSString).range(of: unitStr)
        let attributedTitle = NSMutableAttributedString(string: labelTxt)
        attributedTitle.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Bold", size: 14.0)!,
                NSAttributedString.Key.foregroundColor: textColor!
            ], range: menuRange
        )
        attributedTitle.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Bold", size: 24)!,
                NSAttributedString.Key.foregroundColor: textColor!
            ], range: discountRange
        )
        attributedTitle.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Bold", size: 14)!,
                NSAttributedString.Key.foregroundColor: textColor!
            ], range: unitRange
        )
        return attributedTitle
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 148
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
    
    func loadHistory(){
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let searchUrl = "\(baseUrl)/history/\(String(userId!))"
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
                    historyModel = try decoder.decode([HistoryModel].self, from: data)
                    historyTableView.reloadData()
                } catch let error {
                        print("error decode json \(error)")
                }
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
        }
    }
}
