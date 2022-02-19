//
//  StoreViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2020/12/26.
//

import UIKit
import Alamofire
import FloatingPanel
import SwiftKeychainWrapper

class StoreViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var discountCollectionView: UICollectionView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var topPhotoView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loadStoreView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var lunchImageView: UIImageView!
    @IBOutlet weak var lunchPriceLabel: UILabel!
    @IBOutlet weak var dinnerImageView: UIImageView!
    @IBOutlet weak var dinnerPriceLabel: UILabel!
    @IBOutlet weak var restImageView: UIImageView!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var favFrameView: UIView!
    @IBOutlet weak var topPhotoFrameView: UIView!
    @IBOutlet weak var navNameView: UIView!
    @IBOutlet weak var navNameLabel: UILabel!
    var topPosisionY: CGFloat?
    var middlePosisionY: CGFloat?
    var bottomPosisionY: CGFloat?
    var topPhotoPotisionY: CGFloat?
    var couponTimes: [Int]!
    var photos:[String]!
    let semaphore = DispatchSemaphore(value: 0)
    private var storeDatum: StoreDataum?
    private var storeModel: StoreModel?
    private var imgModel: [ImgModel]?
    private var couponModel: [[CouponModel]]?
    private var discount: [Int]?
    var menuModel: MenuModel?
    var selectedCoupon: CouponModel?
    var currentIndex = 0
    let api = API()
    var id: Int!
    var activityIndicatorView = UIActivityIndicatorView()

    let s3Url = Configuration.shared.s3Url
    let baseUrl = Configuration.shared.apiUrl

    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(0, forKey: "childscroll")
        favFrameView.frame = CGRect(x: self.view.frame.width - 72, y: 152, width: 56, height: 56)
        navNameView.frame = CGRect(x: 0, y: 180, width: self.view.frame.width, height: 0)
        navNameLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
        self.navigationController?.navigationBar.isTranslucent = true
        scrollView.delegate = self

        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let token = KeychainWrapper.standard.string(forKey: "token")
        lunchImageView.layer.cornerRadius = 4
        dinnerImageView.layer.cornerRadius = 4
        restImageView.layer.cornerRadius = 4
        favButton.setImage(UIImage(named: "favorite_normal"), for: .normal)
        favButton.setImage(UIImage(named: "favorite_normal"), for: .disabled)
        favButton.setImage(UIImage(named: "favorite_selected"), for: .selected)
        favButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setButtonFrameView(buttonView: favFrameView)
        if userId != nil && token != nil {
            favButton.isUserInteractionEnabled = true
            favFrameView.isHidden = false
        } else {
            favButton.isUserInteractionEnabled = false
            favFrameView.isHidden = true
        }
        activityIndicatorView.style = .large
        activityIndicatorView.center = view.center
        activityIndicatorView.color = .black
        loadStoreView.addSubview(activityIndicatorView)
        pageControl.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        topPhotoView.showsHorizontalScrollIndicator = false
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.moveToCourseDetail),name: .notifyCourseSelected ,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.goCreateReview),name: .notifyGoReview ,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.openHalfView),name: .notifyCouponSelected ,object: nil)

        discountCollectionView.delegate = self
        discountCollectionView.dataSource = self
        topPhotoView.delegate = self
        topPhotoView.dataSource = self
        topPosisionY = topView.frame.origin.y
        middlePosisionY = middleView.frame.origin.y
        bottomPosisionY = infoView.frame.origin.y
        topPhotoPotisionY = topPhotoFrameView.frame.origin.y
    }
    
    func setButtonFrameView(buttonView: UIView) {
        buttonView.layer.cornerRadius = 28
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOpacity = 0.2
        buttonView.layer.shadowRadius = 3
        buttonView.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        buttonView.layer.masksToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        NotificationCenter.default.addObserver(self,selector: #selector(self.feedScrollMove),name: .notifyScroll ,object: nil)
    }
    
    @objc private func goCreateReview() {
        performSegue(withIdentifier: "toCreateReview" , sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        let now = Date()
        let time = Calendar.current.dateComponents([.hour], from: now)
        let hour = time.hour
        couponTimes = [Int]()
        for i in 0...23 {
            if hour! + i < 24 {
                couponTimes.append(hour! + i)
            } else {
                couponTimes.append(hour! + i - 24)
            }
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        print(statusBarHeight)
        print(navBarHeight)
        scrollView.layoutIfNeeded()
        infoView.layoutIfNeeded()
        infoView.frame.size.height = self.view.bounds.height
        
        contentView.frame.size.height = 400 + infoView.frame.height
        scrollView.contentSize.height = contentView.frame.height
        print(scrollView.contentSize.height)
        print(contentView.frame.size.height)
        print(contentView.frame.height)
        print(infoView.bounds.size.height)
        print(infoView.frame.height)
        
        id = UserDefaults.standard.integer(forKey: "storeId")

        loadStores()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let navigationBar = navigationController!.navigationBar
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    
    
    @objc func moveToCourseDetail(notification: NSNotification) {
        menuModel = notification.userInfo?["MenuData"] as? MenuModel
        performSegue(withIdentifier: "toCourseDetail",sender: nil)
    }
    
    @objc func openHalfView(notification: NSNotification) {
        selectedCoupon = notification.userInfo?["selectedCoupon"] as? CouponModel
        performSegue(withIdentifier: "OpenUseCoupon", sender: nil)
    }
    
    func setCategory(categoryNum: Int) -> String? {
        guard let url = Bundle.main.url(forResource: "category", withExtension: "json") else {
            return ""
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("ファイル読み込みエラー")
        }
        let decoder = JSONDecoder()
        guard let categories = try? decoder.decode([Category].self, from: data) else {
            fatalError("JSON読み込みエラー")
        }
        return categories[categoryNum].name
    }
    
    func setCategoryLabel(category1: String, category2: String) {
        if category1 != "" && category2 !=  "" {
            categoryLabel.text = "\(String(describing: category1))・\(String(describing: category2))"
        } else if category1 != "" {
            categoryLabel.text = category1
        } else if category2 != "" {
            categoryLabel.text = category2
        } else {
            categoryLabel.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCourseDetail") {
            let courseVC: CourseDetailViewController = (segue.destination as? CourseDetailViewController)!
            courseVC.menu = menuModel
            courseVC.store = storeModel?.name
        }
        if (segue.identifier == "toCreateReview") {
            let reviewVC: CreateReviewViewController = (segue.destination as? CreateReviewViewController)!
            reviewVC.navTitle = storeModel?.name
        }
        if (segue.identifier == "OpenUseCoupon") {
            if let vc = segue.destination as? UseCouponViewController {
                vc.modalPresentationStyle = .fullScreen
                vc.coupon = selectedCoupon
                vc.store = storeModel
            }
        }
    }
    
    func loadStores() {
        photos = [String]()
        self.loadStoreView.isHidden = false
        self.activityIndicatorView.startAnimating()
        let searchUrl = "\(baseUrl)/shop/\(String(id!))"
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        var userIdStr = ""
        if userId != nil {
            userIdStr = String(userId!)
        }
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        AF.request(
            searchUrl,
            method: .get,
            parameters: ["user_id": userIdStr],
            encoding: URLEncoding(destination: .queryString),
            headers: headers)
            .responseJSON { [self] response in
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                do {
                    self.storeDatum = try JSONDecoder().decode(StoreDataum.self, from: data)
                    
                    storeModel = storeDatum?.store
                    imgModel = storeDatum?.imgs
                    discount = storeDatum?.discount
                    couponModel = storeDatum?.coupons
                } catch let error {
                    print("error decode json \(error)")
                }
                case .failure(let error):
                    print("RESPONSE ERROR：", error)
                }
                nameLabel.text = storeModel?.name
                navNameLabel.text = storeModel?.name
                let lunchBottom = storeModel?.lunch_estimated_bottom_price
                let lunchHight = storeModel?.lunch_estimated_high_price
                let dinnerBottom = storeModel?.dinner_estimated_bottom_price
                let dinnerHight = storeModel?.dinner_estimated_high_price
                
                if lunchBottom != nil && lunchHight != nil {
                    lunchPriceLabel.text = "￥\(lunchBottom!) 〜 ￥\(lunchHight!)"
                } else if lunchBottom != nil {
                    lunchPriceLabel.text = "￥\(lunchBottom!) 〜"
                } else if lunchHight != nil {
                    lunchPriceLabel.text = "〜 ￥\(lunchHight!)"
                } else {
                    lunchPriceLabel.text = ""
                }
                
                if dinnerBottom != nil && dinnerHight != nil {
                    dinnerPriceLabel.text = "￥\(dinnerBottom!) 〜 ￥\(dinnerHight!)"
                } else if dinnerBottom != nil {
                    dinnerPriceLabel.text = "￥\(dinnerBottom!) 〜"
                } else if dinnerHight != nil {
                    dinnerPriceLabel.text = "〜 ￥\(dinnerHight!)"
                } else {
                    dinnerPriceLabel.text = ""
                }
                
                if storeModel?.holiday != nil {
                    restLabel.text = storeModel!.holiday!
                } else {
                    restLabel.text = ""
                }
                
                let category1 = storeModel?.category_1
                let category2 = storeModel?.category_2
                if category1 != nil && category2 != nil {
                    setCategoryLabel(category1: setCategory(categoryNum: category1!)!, category2: setCategory(categoryNum: category2!)!)
                } else if category1 != nil {
                    setCategoryLabel(category1: setCategory(categoryNum: category1!)!, category2: "")
                } else if category2 != nil {
                    setCategoryLabel(category1: "",category2: setCategory(categoryNum: category2!)!)
                } else {
                    setCategoryLabel(category1: "", category2: "")
                }
                
                if storeModel?.favorite_id != nil {
                    self.favButton.isSelected = true
                } else {
                    self.favButton.isSelected = false
                }

                if imgModel != nil {
                    pageControl.numberOfPages = imgModel!.count
                    topPhotoView.reloadData()
                    discountCollectionView.reloadData()
                }
                
                let shopInfo:[String: Any] = ["storeDatum": storeDatum]
                NotificationCenter.default.post(name: .notifyApi, object: nil,userInfo: shopInfo)
                self.activityIndicatorView.stopAnimating()
                self.loadStoreView.isHidden = true
        }
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
    
    @IBAction func favTapped(_ sender: Any) {
        favButton.isEnabled = false
        api.updateFavoriteState(params:["":""]) { [self](json) in
            if self.favButton.isSelected == true {
                favButton.isSelected = false
                favButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            } else {
                favButton.isSelected = true
                favButton.contentEdgeInsets = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1)
            }
            self.favButton.isEnabled = true
        }
    }
}

extension StoreViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1 {
            return CGSize(width: 57, height: 57)
        } else if (collectionView.tag == 2) {
            return CGSize(width: self.view.frame.width, height: 180)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView == topPhotoView {
            currentIndex = Int(scrollView.contentOffset.x / topPhotoView.frame.size.width)
            pageControl.currentPage = currentIndex
        } else if scrollView == self.scrollView {
            print(scrollView.contentOffset.y)
            if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 80 {
                UserDefaults.standard.setValue(1, forKey: "childscroll")
                navNameView.frame.origin.y = 180
                navNameView.frame.size.height = 0
                if scrollView.contentOffset.y < 30 && scrollView.contentOffset.y > 0 {
                    favFrameView.isHidden = false
                    favFrameView.frame = CGRect(
                        x: favFrameView.frame.minX,
                        y: scrollView.contentOffset.y + 152,
                        width: 56 - scrollView.contentOffset.y,
                        height: 56 - scrollView.contentOffset.y
                    )
                    favFrameView.layer.cornerRadius = favFrameView.frame.width / 2
                    favButton.frame = CGRect(
                        x: 8,
                        y: 8,
                        width: favFrameView.frame.width - 16,
                        height: favFrameView.frame.height - 16
                    )
                }
            } else if scrollView.contentOffset.y >= 80 {
                UserDefaults.standard.setValue(1, forKey: "childscroll")
                favFrameView.isHidden = true
                navNameView.isHidden = false
                
                topPhotoFrameView.frame.origin.y = scrollView.contentOffset.y - 80
                navNameView.isHidden = false
                if scrollView.contentOffset.y <= 180 {
                    navNameView.frame.origin.y = 254 - scrollView.contentOffset.y
                    navNameView.frame.size.height = scrollView.contentOffset.y - 76
                    navNameLabel.frame.size.height = scrollView.contentOffset.y - 76
                }
                
                if scrollView.contentOffset.y >= 310 {
                    infoView.frame.origin.y = scrollView.contentOffset.y + 105
                    scrollView.contentOffset.y = 310
                    scrollView.isScrollEnabled = false
                    let userInfo: [String: Any] = [
                        "offsety": scrollView.contentOffset.y
                    ]
                    NotificationCenter.default.post(name: .notifyMainScroll, object: nil,userInfo:userInfo)
                    UserDefaults.standard.setValue(1, forKey: "childscroll")
                    scrollView.isScrollEnabled = true
                }
            } else {
                UserDefaults.standard.setValue(1, forKey: "childscroll")
                scrollView.contentOffset.y = 0
                topPhotoFrameView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180)
                favFrameView.isHidden = false
                favFrameView.frame = CGRect(
                    x: favFrameView.frame.minX,
                    y: scrollView.contentOffset.y + 152,
                    width: 56,
                    height: 56
                )
                favFrameView.layer.cornerRadius = favFrameView.frame.width / 2
                favButton.frame = CGRect(
                    x: 8,
                    y: 8,
                    width: favFrameView.frame.width - 16,
                    height: favFrameView.frame.height - 16
                )
            }
        }
    }

    
    @objc func feedScrollMove(notification: NSNotification) {
        scrollView.isScrollEnabled = true
        let posisionY:CGFloat = notification.userInfo?["offsety"] as? CGFloat ?? 0
        if posisionY > -100  {
            scrollView.contentOffset.y = scrollView.contentOffset.y + posisionY
        }
        
//
//
//            topView.frame.origin.y = topPosisionY! - posisionY
//            middleView.frame.origin.y = middlePosisionY! - posisionY
//            infoView.frame.origin.y = bottomPosisionY! - posisionY
//            self.navigationController?.navigationBar.tintColor = .clear
//            self.navigationController?.navigationBar.barTintColor = .clear
//        } else {
//            self.navigationController?.navigationBar.tintColor = .white
//            self.navigationController?.navigationBar.barTintColor = .black
//
//
//        }
//        else if posisionY > 320 {
//           middleView.frame.origin.y = middlePosisionY! - 320
//           infoView.frame.origin.y = bottomPosisionY! - 320
//           customNavView.frame.origin.y = 0
//           self.navigationController?.navigationBar.tintColor = .clear
//       } else {
//           middleView.frame.origin.y = middlePosisionY!
//           infoView.frame.origin.y = bottomPosisionY!
//           customNavView.frame.origin.y = -70
//           self.navigationController?.navigationBar.tintColor = .white
//       }
//       if posisionY >= 0 && posisionY <= 214 {
//           topView.frame.origin.y = topPosisionY! - posisionY
//       } else if posisionY > 214 {
//           topView.frame.origin.y = topPosisionY! - 214
//       } else {
//           topView.frame.origin.y = topPosisionY!
//       }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            if couponTimes != nil {
                return couponTimes.count
            }
        } else if (collectionView.tag == 2) {
            if imgModel != nil {
                return imgModel!.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DiscountCollectionViewCell
        
        cell?.selectedView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)

        print(indexPath.row)
        let timeInfo = ["time": indexPath.row]
        NotificationCenter.default.post(name: .notifyTimeSelected, object: nil,userInfo: timeInfo)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? DiscountCollectionViewCell
        
        cell?.selectedView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! DiscountCollectionViewCell
            let imageView =  UIImageView()
            imageView.contentMode = .scaleAspectFit
            
            if discount?[indexPath.row] == 1 {
                imageView.image = UIImage(named: "red_time")
            } else if discount?[indexPath.row] == 2 {
                imageView.image = UIImage(named: "orange_time")
            } else if discount?[indexPath.row] == 3 {
                imageView.image = UIImage(named: "yellow_time")
            } else {
                imageView.image = UIImage(named: "gray_time")
            }
            
            cell.backgroundView = imageView
            cell.selectedView.backgroundColor = .clear
            cell.timeLabel.frame = CGRect(x: 0, y: 5, width: cell.frame.width, height: 21)
            cell.timeLabel.text = "\(String(couponTimes![indexPath.row]))"
            cell.minLabel.frame = CGRect(x: 0, y: 29, width: cell.frame.width, height: 21)
            cell.minLabel.text = "00"
            cell.layer.masksToBounds = false
            return cell
        } else if (collectionView.tag == 2) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopPhotoCell", for: indexPath) as! TopPhotoCell
            
            if imgModel != nil {
                cell.topImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180)
                cell.setupCell(url: "\(s3Url)/\(imgModel![indexPath.row].image_name)")
            }
            return cell
        }
        return UICollectionViewCell()
    }
}
