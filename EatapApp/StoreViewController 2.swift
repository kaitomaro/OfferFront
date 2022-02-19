//
//  StoreViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2020/12/26.
//

import UIKit
import Alamofire

class StoreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var discountCollectionView: UICollectionView!
    
    var times = ["18:00", "19:00", "20:00","21:00", "22:00", "23:00","0:00", "1:00", "2:00","3:00", "4:00", "5:00","6:00", "7:00", "8:00", "9:00","10:00", "11:00", "12:00", "13:00","14:00", "15:00", "16:00", "17:00"]
    
    var discountRate = ["100", "200", "250","500", "100", "300","400", "100", "150","200", "150", "500","600", "700", "800", "900","1000", "900", "200", "3:00","4:00", "150", "600", "7:00"]
    
    var tabInfos = ["menu", "about", "reviews"]
    @IBOutlet weak var tabCollectionView: UICollectionView!
    
    @IBOutlet weak var tabMenuCollectionView: UICollectionView!
    
    struct StoreDataum: Codable {
        var user: UserModel
    }
    
    struct UserModel: Codable {
        var id: Int
        var name: String
        var lunch_start_time: String?
        var lunch_end_time: String?
        var dinner_start_time: String?
        var dinner_end_time: String?
        var post_code: String
        var adress: String
        var phone: String?
    }
    
    struct CouponModel: Codable {
        var id:Int?
        var time_id:Int?
        var service_type:Int?
        var image_path: String?
        var price:Int?
        var discount:Int?
        var name: String?
    }
    let semaphore = DispatchSemaphore(value: 0)
    private var storeDatum: StoreDataum?
    private var userModel: UserModel?
    private var couponModel: CouponModel?
    
    var id:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        discountCollectionView.delegate = self
        discountCollectionView.dataSource = self
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        tabMenuCollectionView.delegate = self
        tabMenuCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadStores()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        self.navigationController?.navigationBar.tintColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return times.count
        } else if collectionView.tag == 2{
            return tabInfos.count
        } else {
            return 3
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! DiscountCollectionViewCell
            cell.layer.cornerRadius = 8
            cell.discountLabel.text = "\(discountRate[indexPath.row])円"
            cell.timeLabel.text = times[indexPath.row]
            cell.layer.masksToBounds = false
            return cell
        } else if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! TabCollectionViewCell
            cell.infoTagLabel.text! = tabInfos[indexPath.row]
            print(cell.infoTagLabel.text!)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabMenuCell", for: indexPath) as! TabMenuCollectionViewCell
            cell.backgroundColor = .blue
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let returnSize = CGSize(width: 200, height: 100)
        return returnSize
    }
        
    func loadStores(){
        let baseUrl = "http://127.0.0.1:8000/api/"
        let searchUrl = "\(baseUrl)stores/\(String(id!))"
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        AF.request(
            searchUrl,
            method: .get,
            parameters: nil,
            encoding: URLEncoding(destination: .queryString),
            headers: headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success:
                    guard let data = response.data else { return }
                    do {
                        self.storeDatum = try JSONDecoder().decode(StoreDataum.self, from: data)
                        print(self.storeDatum)
                        userModel = storeDatum?.user
                    } catch let error {
                            print("error decode json \(error)")
                    }
                case .failure(let error):
                    print("RESPONSE ERROR：", error)
                }
                nameLabel.text = userModel?.name
                if userModel?.post_code != nil && userModel?.adress != nil{
                    if userModel!.adress.contains("東京都豊島区") {
                        let adress = userModel!.adress.replacingOccurrences(of:"東京都豊島区", with:"")
                        adressLabel.text = "\(userModel!.post_code) \(adress)"
                    } else {
                        adressLabel.text = "\(userModel!.post_code) \(userModel!.adress)"
                    }
                }
                if userModel?.lunch_start_time != nil && userModel?.lunch_end_time != nil{
                    if userModel?.dinner_start_time != nil && userModel?.dinner_end_time != nil{
                        timeLabel.text = "\(userModel!.lunch_start_time!)~\(userModel!.lunch_end_time!), \(userModel!.dinner_start_time!)~\(userModel!.dinner_end_time!)"
                    } else{
                        timeLabel.text = "\(userModel!.lunch_start_time!)~\(userModel!.lunch_end_time!)"
                    }
                } else if userModel?.dinner_start_time != nil && userModel?.dinner_end_time != nil{
                        timeLabel.text = "\(userModel!.dinner_start_time!)~\(userModel!.dinner_end_time!)"
                }else {
                    timeLabel.text = ""

                }
                
                if userModel?.phone != nil{
                    phoneLabel.text = "TEL: \(userModel!.phone!)"
                } else {
                    phoneLabel.text = "TEL: "
                }
            }
    }
}
