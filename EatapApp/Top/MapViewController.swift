//
//  ViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2020/11/06.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import FloatingPanel
import SwiftKeychainWrapper


 
struct Category: Codable {
    var num: String
    var name: String
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FloatingPanelControllerDelegate
{
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var searchPickerView: UIPickerView!
    @IBOutlet weak var pickerFrameView: UIView!
    @IBOutlet weak var searchPinButton: UIButton!
    @IBOutlet weak var runningOnlySwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var searchButtonView: UIView!
    
    @IBOutlet weak var favButtonView: UIView!
    
    @IBOutlet weak var myPlaceButtonView: UIView!
    
    @IBOutlet weak var myPlaceButton: UIButton!
    @IBOutlet weak var closePickerButton: UIButton!
    @IBOutlet weak var selectedTimeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var lunchImageView: UIImageView!
    @IBOutlet weak var dinnerImageView: UIImageView!
    @IBOutlet weak var lunchPriceLabel: UILabel!
    @IBOutlet weak var dinnerPriceLabel: UILabel!
    
    private var storeMapModels:[StoreMapModel] = []
    
    var myLocationManager:CLLocationManager!
    var userLoc: CLLocation?
    var fuga:[String]!
    var id:Int!
    let pages = ["menu", "about", "reviews"]
    let api = API()
    var fav: String?
    var category: String?
    var timeData:[Int]!
    var time: Int?
    var categoryData = ["すべて", "和食", "洋食", "中華", "その他", "カフェ・喫茶店", "バー・居酒屋"]
    let userDefaults = UserDefaults.standard
    let now = Date()
    var activityIndicatorView = UIActivityIndicatorView()
    var fpc: FloatingPanelController!
    var limitPins = 0
    private var navAlertModel: NavAlertModel?
//
    let s3Url = Configuration.shared.s3Url
    let baseUrl = Configuration.shared.apiUrl
//    let s3Url = "https://eatapbucket.s3-ap-northeast-1.amazonaws.com"
//    let baseUrl = "https://www.eatap.co.jp/api"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        dinnerImageView.layer.cornerRadius = 2
        lunchImageView.layer.cornerRadius = 2
        infoView.layer.cornerRadius = 5
        fav = "0"
        switchLabel.text = "クーポン\n発行中のみ"
        
        let now = Date()
        let nowTime = Calendar.current.dateComponents([.hour], from: now)
        time = nowTime.hour
        timeData = [Int]()
        for i in 0...23 {
            if time! + i < 24 {
                timeData.append(time! + i)
            } else {
                timeData.append(time! + i - 24)
            }
        }
        
        view.backgroundColor = .lightGray
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .medium
        activityIndicatorView.color = .gray
        view.addSubview(activityIndicatorView)
        searchPickerView.selectRow(0, inComponent: 1, animated: true)
        category = "0"
        pickerFrameView.layer.cornerRadius = 40
        pickerFrameView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        searchPinButton.layer.cornerRadius = 20
        setIcons()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        infoView.addGestureRecognizer(singleTapGesture)
        loadStores(time: String(time!),category: category!)
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager!.requestWhenInUseAuthorization()
        mainMapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: false)
        let latitude = 35.728926
        let longitude = 139.71038
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        mainMapView.setCenter(location, animated:true)
        mainMapView.delegate = self
        var region = mainMapView.region
        region.center = location
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        mainMapView.setRegion(region, animated:true)
        mainMapView.addSubview(infoView)
        createPickerView(pickerView: searchPickerView)
        
        mainMapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotationView.identifier)
        mainMapView.register(CustomClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomClusterAnnotationView.identifier)
        getDeviceToken()
    }
    
    func getDeviceToken () {
        let appDeviceToken = KeychainWrapper.standard.string(forKey: "AppDeviceToken")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        if appDeviceToken != nil {
            if userId != nil {
                api.sendAppDeviceToken(params: [
                    "app_device_token": appDeviceToken!,
                    "user_id": String(userId!),
                    "platform": "ios"
                    
                ]) { (json) in
                    print(json)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func createPickerView(pickerView: UIPickerView) {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var doneItem = UIBarButtonItem()
        toolbar.setItems([spacelItem, doneItem], animated: true)
    }

    func showSemiModal(vc:SemiModalVC){
        if children.isEmpty == false {
            fpc.removePanelFromParent(animated: true)
        }
        fpc = FloatingPanelController() as FloatingPanelController?
        fpc.layout = CustomFloatingPanelLayout()
        fpc.delegate = self
        fpc.surfaceView.appearance.cornerRadius = 25
        fpc.set(contentViewController: vc)
        fpc.addPanel(toParent: self)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let token = KeychainWrapper.standard.string(forKey: "token")
        if userId != nil && token != nil {
            favoriteButton.isUserInteractionEnabled = true
            favoriteButton.setTitleColor(.white, for: .normal)

        } else {
            favoriteButton.isUserInteractionEnabled = false
            favoriteButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4), for: .normal)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLoc = manager.location
    }
    
    @objc private func didTapFavoriteButton(_ sender: UIButton) {
        favoriteButton.isEnabled = false
        print("favorite tapped")
        if sender.isSelected == true {
            favoriteButton.isSelected = false
            fav = "0"
            print("shiro")
            favoriteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            fav = "1"
            favoriteButton.isSelected = true

            favoriteButton.contentEdgeInsets = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1)
            print("kiiro")
        }
        mainMapView.removeAnnotations(mainMapView.annotations)
        loadStores(time: String(time!), category: category!)
    }
    
    @objc private func didTapMyPlaceButton(_ sender: UIButton) {
        print("place tapped")
        if self.userLoc != nil {
            mainMapView.setCenter(self.mainMapView.userLocation.coordinate, animated: true)
        } else {
            let alert: UIAlertController = UIAlertController(title: "現在地の読み込みには位置情報サービスが必要です。", message: "設定画面で位置情報サービスをオンにしてください。", preferredStyle:  UIAlertController.Style.alert)
            let confirmAction: UIAlertAction = UIAlertAction(title: "設定へ", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                let url = URL(string: "app-settings:root=General&path=jp.co.eatap")
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    @objc private func didTapSearchButton(_ sender: UIButton) {
        if children.isEmpty == false {
            fpc.removePanelFromParent(animated: true)
        }
        if pickerFrameView.frame.origin.y == mainMapView.frame.maxY {
            pickerFrameView.frame.origin.y = pickerFrameView.frame.origin.y - 360
            print(pickerFrameView.frame.origin.y)
        } else {
            pickerFrameView.frame.origin.y = pickerFrameView.frame.origin.y + 360
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        default:
            break
        }
    }

    func loadStores(time: String, category: String){
        activityIndicatorView.startAnimating()
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                self.mainMapView.backgroundColor = UIColor.white
                var latitude:Double?
                var longitude:Double?
                let searchUrl = "\(self.baseUrl)/map"
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
                    parameters: ["time": time, "category": category, "fav": self.fav!, "user_id": userIdStr],
                    encoding: URLEncoding(destination: .queryString),
                    headers: headers).responseJSON{ [self] response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else { return }
                        do {
                            let decoder = JSONDecoder()
                            let storeDatum = try decoder.decode([StoreMapModel].self, from: data)
                            for storeMapModel in storeDatum{
                                latitude = storeMapModel.latitude
                                longitude = storeMapModel.longitude
                                
                                let loc:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                                if self.fav == "1" &&
                                    storeMapModel.favorite_id != nil &&
                                    self.limitPins == 1 &&
                                    storeMapModel.coupon_id != nil &&
                                    storeMapModel.opened == 1
                                {
                                    addAnnotations(loc: loc, storeMapModel: storeMapModel)
                                }
                                else if self.fav == "1" &&
                                    storeMapModel.favorite_id != nil &&
                                    self.limitPins == 0
                                {
                                    addAnnotations(loc: loc, storeMapModel: storeMapModel)

                                }
                                else if self.fav == "0" &&
                                    self.limitPins == 1 &&
                                    storeMapModel.coupon_id != nil &&
                                    storeMapModel.opened == 1
                                {
                                    addAnnotations(loc: loc, storeMapModel: storeMapModel)
                                }
                                else if self.fav == "0" && self.limitPins == 0
                                {
                                    addAnnotations(loc: loc, storeMapModel: storeMapModel)
                                }
                                self.activityIndicatorView.stopAnimating()
                                self.mainMapView.backgroundColor = UIColor.clear
                                
                            }
                        } catch let error {
                            print("error decode json \(error)")
                        }
                    case .failure(let error):
                        print("RESPONSE ERROR：", error)
                    }
                    self.favoriteButton.isEnabled = true
                    self.searchButton.isEnabled = true
                }
            }
        }
    }
    
    private func addAnnotations(loc:CLLocationCoordinate2D, storeMapModel: StoreMapModel) {
        let pin = CustomAnnotaion()
        pin.coordinate = loc
        pin.title = storeMapModel.name
        pin.storeId = storeMapModel.id
        pin.imageName = storeMapModel.top_image
        let lunchBottom = storeMapModel.lunch_estimated_bottom_price
        let lunchHight = storeMapModel.lunch_estimated_high_price
        let dinnerBottom = storeMapModel.dinner_estimated_bottom_price
        let dinnerHight = storeMapModel.dinner_estimated_high_price
        
        if lunchBottom != nil && lunchHight != nil {
            pin.lunchPrice = "￥\(lunchBottom!) 〜 ￥\(lunchHight!)"
        } else if lunchBottom != nil {
            pin.lunchPrice = "￥\(lunchBottom!) 〜"
        } else if lunchHight != nil {
            pin.lunchPrice = "〜 ￥\(lunchHight!)"
        } else {
            pin.lunchPrice = ""
        }
        
        if dinnerBottom != nil && dinnerHight != nil {
            pin.dinnerPrice = "￥\(dinnerBottom!) 〜 ￥\(dinnerHight!)"
        } else if dinnerBottom != nil {
            pin.dinnerPrice = "￥\(dinnerBottom!) 〜"
        } else if dinnerHight != nil {
            pin.dinnerPrice = "〜 ￥\(dinnerHight!)"
        } else {
            pin.dinnerPrice = ""
        }
        
        pin.clusteringIdentifier = "clusteringIdentifier"
        if storeMapModel.discount == nil {
            pin.discount = 0
        } else {
            pin.discount = storeMapModel.discount
        }
        pin.priority = storeMapModel.priority
        
        if storeMapModel.category_1 != nil {
            if storeMapModel.category_1! != 5 {
                pin.cafeOrRest = 1
            } else {
                pin.cafeOrRest = 5
            }
        } else {
            pin.cafeOrRest = 1
        }
        if storeMapModel.category_1 != nil {
            pin.category1 = setCategory(categoryNum: storeMapModel.category_1!)
        } else {
            pin.category1 = ""
        }
        
        if storeMapModel.category_2 != nil {
            pin.category2 = setCategory(categoryNum: storeMapModel.category_2!)
        } else {
            pin.category2 = ""
        }
        self.mainMapView.addAnnotation(pin)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKClusterAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomClusterAnnotationView.identifier) as? CustomClusterAnnotationView
            let annotation = annotation as? MKClusterAnnotation
            if annotationView == nil {
                annotationView = CustomClusterAnnotationView(annotation: annotation, reuseIdentifier: "CustomClusterAnnotationView")
            }
            guard let pinList = annotation!.memberAnnotations as? [CustomAnnotaion] else{
                return annotationView
            }
            let priority = pinList.reduce(pinList[0].priority!, { min($0, $1.priority!) })
            annotationView?.glyphTintColor = .white
            if priority == 1 {
                annotationView!.markerTintColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
            } else if priority == 2 {
                annotationView!.markerTintColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
            } else if priority == 3 {
                annotationView!.markerTintColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
            } else {
                annotationView!.markerTintColor = #colorLiteral(red: 0.6745098039, green: 0.6745098039, blue: 0.6745098039, alpha: 1)
            }
            return annotationView
        } else if annotation is CustomAnnotaion {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier) as? CustomAnnotationView
            let annotation = annotation as! CustomAnnotaion
            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotationView")
            }
            annotationView?.clusteringIdentifier = annotation.clusteringIdentifier
            if annotation.discount == nil {
                annotation.discount = 0
            }
            
            if annotation.priority! == 1  {
                annotationView?.markerTintColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
            } else if annotation.priority! == 2 {
                annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
            } else if annotation.priority! == 3 {
                annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
            } else {
                annotationView?.markerTintColor = #colorLiteral(red: 0.6745098039, green: 0.6745098039, blue: 0.6745098039, alpha: 1)
            }
            annotationView?.contentMode = UIView.ContentMode.scaleAspectFill
            annotationView?.glyphImage = UIImage(named: "knife_and_fork")
            annotationView?.glyphTintColor = .white
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? CustomAnnotaion{
            if children.isEmpty == false {
                fpc.removePanelFromParent(animated: true)
            }
            
            if infoView.isHidden == true {
                infoView.isHidden = false
                myPlaceButtonView.transform = CGAffineTransform(translationX: 0, y: -130)
            }
            
            let title = annotation.title
            let topImage = annotation.imageName
            let category1 = annotation.category1
            let category2 = annotation.category2
            let lunchPrice = annotation.lunchPrice
            let dinnerPrice = annotation.dinnerPrice
            
            if title != nil{
                nameLabel.text = title
            } else {
                nameLabel.text = nil
            }
            
            if category1 != "" && category2 !=  "" {
                categoryLabel.text = "\(String(describing: category1!))・\(String(describing: category2!))"
            } else if category1 != "" {
                categoryLabel.text = category1
            } else if category2 != "" {
                categoryLabel.text = category2
            } else {
                categoryLabel.text = ""
            }
            
            if lunchPrice != nil {
                lunchPriceLabel.text = lunchPrice!
            } else {
                lunchPriceLabel.text = ""
            }
            
            if dinnerPrice != nil {
                dinnerPriceLabel.text = dinnerPrice!
            } else {
                dinnerPriceLabel.text = ""
            }
            
            if topImage != nil {
                storeImageView.image = getImageByUrl(url: "\(s3Url)/\(topImage!)")
            } else {
               print("画像ない")
            }
            id = annotation.storeId!
            

        }
        
        if let cluster = view.annotation as? MKClusterAnnotation {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MapModal") as? SemiModalVC else {
                return
            }
            guard let pinList = cluster.memberAnnotations as? [CustomAnnotaion] else{
                return
            }
            vc.infos = pinList
            self.showSemiModal(vc: vc)
        }
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        searchButton.isEnabled = false
        mainMapView.removeAnnotations(mainMapView.annotations)
        pickerFrameView.frame.origin.y = pickerFrameView.frame.origin.y + 360
        let nowTime = Calendar.current.dateComponents([.hour], from: now)
        var currentHour = nowTime.hour
        if time == currentHour {
            selectedTimeLabel.text = "現在時刻"
        } else if time! > currentHour! {
            selectedTimeLabel.text = "\(String(time!)):00〜"
        } else {
            selectedTimeLabel.text = "翌\(String(time!)):00〜"
        }
        loadStores(time: String(time!), category: category!)
    }
    
    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        if id != nil {
            if children.isEmpty == false {
                fpc.removePanelFromParent(animated: true)
            }
            performSegue(withIdentifier: "toStoreViewController",sender: nil)
        }
    }
    
    @IBAction func changedSwotchValue(_ sender: Any) {
        if runningOnlySwitch.isOn {
            limitPins = 1
        } else {
            limitPins = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toStoreViewController") {
            let storeVC: StoreViewController = (segue.destination as? StoreViewController)!
            storeVC.id = id
            userDefaults.set(id, forKey: "storeId")
        }
    }
    
    func setIcons() {
        searchButton.addTarget(self, action: #selector(didTapSearchButton(_:)), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(didTapFavoriteButton(_:)), for: .touchUpInside)
        favoriteButton.setImage(UIImage(named: "favorite_normal"), for: .normal)
        favoriteButton.setImage(UIImage(named: "favorite_selected"), for: .selected)
        myPlaceButton.addTarget(self, action: #selector(didTapMyPlaceButton(_:)), for: .touchUpInside)
        
        setButtonFrameView(buttonView: favButtonView)
        setButtonFrameView(buttonView: searchButtonView)
        setButtonFrameView(buttonView: myPlaceButtonView)
        
    }
    
    func setButtonFrameView(buttonView: UIView) {
        buttonView.layer.cornerRadius = 26
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOpacity = 0.2
        buttonView.layer.shadowRadius = 3
        buttonView.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        buttonView.layer.masksToBounds = false
    }
    
    func floatingPanelDidEndDragging(_ fpc: FloatingPanelController, willAttract attract: Bool) {
    }
    
    @IBAction func closePickerFrame(_ sender: Any) {
        pickerFrameView.frame.origin.y = pickerFrameView.frame.origin.y + 400
    }

}


extension MapViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            category = String(row)
        } else {
            time = timeData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 47
    }
}

extension MapViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()


        label.font = UIFont(name: "NotoSansJP-Regular", size: 19.0)
        label.textAlignment = .center
        
        if component == 0 {
            label.text = categoryData[row]
            return label
        } else {
            if row == 0 {
                label.text = "現在時刻 〜"
            } else if timeData[row] > time! {
                label.text = "\(timeData[row]):00 〜"
            } else {
                label.text = "翌\(timeData[row]):00 〜"
            }
            return label
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return categoryData.count
        } else {
            return timeData.count
        }
    }
}
