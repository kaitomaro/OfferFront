import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftKeychainWrapper

class StoreMenuViewController: UIViewController, IndicatorInfoProvider, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate{
    
    private var storeDatum: StoreDataum?
    private var storeModel: StoreModel?
    private var couponsModel: [[CouponModel]]?
    private var timeModel: [TimeModel]?
    var couponsOfSelected: [CouponModel]?
    let api = API()
    var itemInfo: IndicatorInfo = "クーポン"
    var id: Int?
    var now = Date()
    var time: DateComponents!
    @IBOutlet weak var menuCollectionview:UICollectionView!

    let s3Url = Configuration.shared.s3Url
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuCollectionview.delegate = self

        menuCollectionview.frame = CGRect(x: 0, y: 10, width: self.view.frame.width, height: self.view.frame.height)
        NotificationCenter.default.addObserver(self,selector: #selector(self.getObject),name: .notifyApi ,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.changeTime),name: .notifyTimeSelected ,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.feedScrollMove),name: .notifyMainScroll ,object: nil)
        time = Calendar.current.dateComponents([.hour], from: now)
        let hour = time.hour
        id = UserDefaults.standard.integer(forKey: "storeId")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
        if UserDefaults.standard.integer(forKey: "childscroll") == 1 {
            menuCollectionview.isScrollEnabled = true
        } else {
            menuCollectionview.isScrollEnabled = false
        }
    }
    
    
    @objc func getObject(notification: NSNotification) {
        storeDatum = notification.userInfo?["storeDatum"] as? StoreDataum
        couponsModel = storeDatum?.coupons
        print(storeModel)
        if couponsModel != nil {
            if couponsModel!.count > 0 && storeDatum?.store.opened == 1 {
                couponsOfSelected = couponsModel?[0]
                couponsOfSelected!.sort(by: {$0.priority! < $1.priority!})
            } else {
                couponsOfSelected = []
            }
        }
         else {
            couponsOfSelected = []
        }
        menuCollectionview.reloadData()
    }
    
    @objc func changeTime(notification: NSNotification) {
        let time = notification.userInfo?["time"] as? Int
    
        if couponsModel != nil {
            if couponsModel!.count > 0 && storeDatum?.store.opened == 1 {
                couponsOfSelected = couponsModel?[time!]
                couponsOfSelected!.sort(by: {$0.priority! < $1.priority!})
            } else {
                couponsOfSelected = []
            }
        }
        else {
            couponsOfSelected = []
        }
        menuCollectionview.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if couponsOfSelected != nil {
            if couponsOfSelected!.count >= 1 {
                return couponsOfSelected!.count
            } else {
                return 1
            }
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func setOriginalPriceLabel(sentence: String, price: String)->NSMutableAttributedString {
        let sentence = sentence
        let sentenceRange = (sentence as NSString).range(of: sentence)
        let priceRange = (sentence as NSString).range(of: price)
        let attributedOriginalPrice = NSMutableAttributedString(string: sentence)
        attributedOriginalPrice.addAttributes(
            [
                .strikethroughStyle: 1,
                .font: UIFont(name: "NotoSansJP-Bold", size: 14)!
            ], range: sentenceRange
        )
        attributedOriginalPrice.addAttributes(
            [
                .strikethroughStyle: 1,
                .font: UIFont(name: "NotoSansJP-Bold", size: 18)!
            ], range: priceRange
        )
        return attributedOriginalPrice
    }
    
    @objc func feedScrollMove(notification: NSNotification) {
        let posisionY:CGFloat = notification.userInfo?["offsety"] as? CGFloat ?? 0
        print(posisionY)
        menuCollectionview.isScrollEnabled = true
    }
    
    func setDiscountPriceLabel(sentence: String, price: String)->NSMutableAttributedString {
        let sentence = sentence
        let minusRange = (sentence as NSString).range(of: "-")
        let spaceRange = (sentence as NSString).range(of: " ")
        let priceRange = (sentence as NSString).range(of: price)
        let yenRange = (sentence as NSString).range(of: " 円")
        
        let attributedOriginalPrice = NSMutableAttributedString(string: sentence)
        if Int(price)! < 1000 {
            attributedOriginalPrice.addAttributes(
                [
                    .font: UIFont(name: "NotoSansJP-Bold", size: 50)!
                ], range: minusRange
            )
            attributedOriginalPrice.addAttributes(
                [
                    .font: UIFont(name: "NotoSansJP-Bold", size: 50)!
                ], range: priceRange
            )
        } else {
            attributedOriginalPrice.addAttributes(
                [
                    .font: UIFont(name: "NotoSansJP-Bold", size: 46)!
                ], range: minusRange
            )
            attributedOriginalPrice.addAttributes(
                [
                    .font: UIFont(name: "NotoSansJP-Bold", size: 46)!
                ], range: priceRange
            )
        }
        
        attributedOriginalPrice.addAttributes(
            [
                .font: UIFont(name: "NotoSansJP-Bold", size: 18)!
            ], range: spaceRange
        )
        
        
        attributedOriginalPrice.addAttributes(
            [
                .font: UIFont(name: "NotoSansJP-Bold", size: 18)!
            ], range: yenRange
        )
        return attributedOriginalPrice
    }
    
    func setDiscountPercentLabel(sentence: String, price: String)->NSMutableAttributedString {
        let sentence = sentence
        let minusRange = (sentence as NSString).range(of: "-")
        let spaceRange = (sentence as NSString).range(of: " ")
        let priceRange = (sentence as NSString).range(of: price)
        let yenRange = (sentence as NSString).range(of: " ％")
        let attributedOriginalPrice = NSMutableAttributedString(string: sentence)
        attributedOriginalPrice.addAttributes(
            [
                .font: UIFont(name: "NotoSansJP-Bold", size: 50)!
            ], range: minusRange
        )
        
        attributedOriginalPrice.addAttributes(
            [
                .font: UIFont(name: "NotoSansJP-Bold", size: 18)!
            ], range: spaceRange
        )
        
        attributedOriginalPrice.addAttributes(
            [
                .font: UIFont(name: "NotoSansJP-Bold", size: 50)!
            ], range: priceRange
        )
        attributedOriginalPrice.addAttributes(
            [
                .font: UIFont(name: "NotoSansJP-Bold", size: 18)!
            ], range: yenRange
        )
        return attributedOriginalPrice
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if couponsOfSelected != nil  {
            if couponsOfSelected!.count >= 1 {
                let name = couponsOfSelected![indexPath.row].name!
                let price = String(couponsOfSelected![indexPath.row].price!)
                let priority = couponsOfSelected?[indexPath.row].priority
                let imagePath = couponsOfSelected![indexPath.row].image_path!
                let telephoneReservation = couponsOfSelected?[indexPath.row].telephone_reservation
                let firstTimeDiscount =  couponsOfSelected?[indexPath.row].first_time_discount
                let serviceType = couponsOfSelected?[indexPath.row].service_type
                let discount = couponsOfSelected![indexPath.row].discount!
                let discountType = couponsOfSelected![indexPath.row].discount_type
                
                if serviceType == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NormalDiscountCell", for: indexPath) as! NormalDiscountCell
                    cell.contentView.frame = CGRect(x: 16, y: 0, width: self.view.frame.width - 32, height: 139)
                    cell.setPosition(collectionView: menuCollectionview)
                    
                    cell.couponTitleLabel.text = name
                    cell.setupCell(url: "\(s3Url)/\(imagePath)")
                    cell.originalPriceLabel.text = "定価\(price)円"
                    cell.discountPriceLabel.text = "- \(discount) 円"
                    let originalPriceSentence = cell.originalPriceLabel.text!
                    cell.originalPriceLabel.attributedText = setOriginalPriceLabel(sentence: originalPriceSentence, price: price)
                    let discountPriceSentence = cell.discountPriceLabel.text!
                    cell.discountPriceLabel.attributedText = setDiscountPriceLabel(sentence: discountPriceSentence, price: "\(discount)")
                    if priority == 1 {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
                    } else if priority == 2 {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
                    } else {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
                    }
                    
                    if telephoneReservation == 1 && firstTimeDiscount == 1 {
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "要電話予約"
                        cell.repeatableLabel2.isHidden = false
                        cell.repeatableLabel2.text = "初回限定"
                    } else if firstTimeDiscount == 1 {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "初回限定"
                    } else if telephoneReservation == 1 {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "要電話予約"
                    } else {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = true
                    }
                    print(cell.contentView.frame.size)
                    print(self.view.frame.size)
                    print(collectionView.frame.size)
                    return cell
                } else if serviceType == 1 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FreeDiscountCell", for: indexPath) as! FreeDiscountCell
                    cell.contentView.frame = CGRect(x: 16, y: 0, width: self.view.frame.width - 32, height: 139)
                    cell.discountPriceLabel.text = "無料"
                    cell.setPosition(collectionView: menuCollectionview)
                    cell.couponTitleLabel.text = name
                    cell.setupCell(url: "\(s3Url)/\(imagePath)")
                    cell.originalPriceLabel.text = "定価\(price)円"
                    let originalPriceSentence = cell.originalPriceLabel.text!
                    cell.originalPriceLabel.attributedText = setOriginalPriceLabel(sentence: originalPriceSentence, price: price)
                    if priority == 1 {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
                    } else if priority == 2 {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
                    } else {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
                    }
                    
                    if telephoneReservation == 1 && firstTimeDiscount == 1 {
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "要電話予約"
                        cell.repeatableLabel2.isHidden = false
                        cell.repeatableLabel2.text = "初回限定"
                    } else if firstTimeDiscount == 1 {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "初回限定"
                    } else if telephoneReservation == 1 {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "要電話予約"
                    } else {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = true
                    }
                    print(cell.contentView.frame.size)
                    print(self.view.frame.size)
                    print(collectionView.frame.size)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupDiscountCell", for: indexPath) as! GroupDiscountCell
                    cell.contentView.frame = CGRect(x: 16, y: 0, width: self.view.frame.width - 32, height: 139)
                    cell.setPosition(collectionView: menuCollectionview)
                    cell.couponTitleLabel.text = name
                    cell.setupCell(url: "\(s3Url)/\(imagePath)")
                    if discountType == 0 {
                        cell.discountLabel.text = "- \(discount) 円"
                        cell.discountLabel.attributedText = setDiscountPriceLabel(sentence: cell.discountLabel.text!, price: "\(discount)")
                    } else {
                        cell.discountLabel.text = "- \(discount) ％"
                        cell.discountLabel.attributedText = setDiscountPercentLabel(sentence: cell.discountLabel.text!, price: "\(discount)")
                    }
                    
                    
                    
                    if priority == 1 {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
                    } else if priority == 2 {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
                    } else {
                        cell.coloredView.backgroundColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
                    }
                    
                    if telephoneReservation == 1 && firstTimeDiscount == 1 {
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "要電話予約"
                        cell.repeatableLabel2.isHidden = false
                        cell.repeatableLabel2.text = "初回限定"
                    } else if firstTimeDiscount == 1 {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "初回限定"
                    } else if telephoneReservation == 1 {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = false
                        cell.repeatableLabel.text = "要電話予約"
                    } else {
                        cell.repeatableLabel2.isHidden = true
                        cell.repeatableLabel.isHidden = true
                    }
                    print(cell.contentView.frame.size)
                    print(self.view.frame.size)
                    print(collectionView.frame.size)
                    return cell
                }
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoneCell", for: indexPath) as! NoneCell
                cell.contentView.frame = CGRect(x: 16, y: 0, width: self.view.frame.width - 32, height: 139)
                cell.setPosition(collectionView: menuCollectionview)
                return cell
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoneCell", for: indexPath) as! NoneCell
        cell.setPosition(collectionView: menuCollectionview)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let token = KeychainWrapper.standard.string(forKey: "token")
        if userId != nil && token != nil {
            let shopInfo:[String: Any] = [
                "selectedCoupon" : couponsOfSelected![indexPath.row],
            ]
            NotificationCenter.default.post(name: .notifyCouponSelected, object: nil,userInfo: shopInfo)
        } else {
            let alert = UIAlertController(title: "ログイン画面へ", message: "クーポンの利用にはログインする必要があります", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                print("Cancel button tapped")
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
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == menuCollectionview {
            var userInfo: [String: Any] = [
                "offsety": scrollView.contentOffset.y
            ]
            
            if scrollView.contentOffset.y <= 0 {
                print(scrollView.contentOffset)
                if scrollView.contentOffset.y < -310 {
                    scrollView.contentOffset.y = -310
                    userInfo["offsety"] = -310
                }
                menuCollectionview.isScrollEnabled = false
                NotificationCenter.default.post(name: .notifyScroll, object: nil,userInfo:userInfo)
                UserDefaults.standard.setValue(0 , forKey: "childscroll")
            }
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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

extension StoreMenuViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 32, height: 139)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 300, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
