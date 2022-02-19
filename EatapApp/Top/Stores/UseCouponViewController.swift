//
//  UseCouponViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/06/03.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftKeychainWrapper
import CoreLocation

class UseCouponViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate, UIPickerViewDelegate, UIPickerViewDataSource,CLLocationManagerDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var firstTimeLabel: UILabel!
    @IBOutlet weak var telReserveLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var statementTextView: UITextView!
    @IBOutlet weak var howManyLabel: UILabel!
    @IBOutlet weak var howManyTextField: UITextField!
    @IBOutlet weak var thankView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var useCouponView: UIView!
    @IBOutlet weak var videoFrameView: UIView!
    @IBOutlet weak var couponTicketView: UIImageView!
    @IBOutlet weak var goLotoLabel: UILabel!
    
    @IBOutlet weak var thankFrameView: UIView!
    
    private var myLocationManager:CLLocationManager!
    var coupon: CouponModel?
    var store: StoreModel?
    private var todayModel: [HistoryModel]?
    private var historyModel: [HistoryModel]?
    private var historyDatum: HistoryDatum?
    var player:AVAudioPlayer?

    
    var str: String?
    let captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var pickerView = UIPickerView()
    var peopleData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var people: Int?
    var now = Date()
    var api = API()
    var userLoc: CLLocation?
    var activityIndicatorView = UIActivityIndicatorView()
    
    let baseUrl = Configuration.shared.apiUrl
    let baseCouponUrl = Configuration.shared.couponUrl
    

    var usedSwicth: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoFrameView.layer.cornerRadius = 5
        couponTicketView.layer.cornerRadius = 46
        goLotoLabel.layer.cornerRadius = 5
        goLotoLabel.layer.masksToBounds = true
        thankView.layer.cornerRadius = 8
        storeNameLabel.text = store?.name
        initTextView()
        initTitleLabel()
        activityIndicatorView.style = .large
        activityIndicatorView.center = view.center
        activityIndicatorView.color = .black
        view.addSubview(activityIndicatorView)
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        howManyTextField.text = "1"
        pickerView.selectRow(0, inComponent: 0, animated: false)
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.startUpdatingLocation()
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = kCLDistanceFilterNone
        setCouponSubOptions()
        useButton.layer.cornerRadius = 23
        createPickerView()
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowRadius = 5
        bottomView.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        bottomView.layer.masksToBounds = false

    }
    
    func initTextView() {
        let titleTxt = "注意事項"
        let sentence = "・他クーポンとの併用はできません。\n・クーポン利用時はQRコードを読み取ってください。\n・対象時間のみ有効です。\n・クーポンの内容についてご不明点などございましたら、店舗のスタッフまで語彙確認ください。\n・本クーポン内容については、予告なく変更・終了する場合があります。"
        statementTextView.text = titleTxt + "\n" + sentence
        
        let text = statementTextView.text!
        statementTextView.textColor = #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
        let titleRange = (text as NSString).range(of: "注意事項")
        let sentenceRange = (text as NSString).range(of: sentence)
        let attributedKiyaku = NSMutableAttributedString(string: text)
        attributedKiyaku.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 14.0)!
            ], range: titleRange
        )
        attributedKiyaku.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 10.0)!
            ], range: sentenceRange
        )
        statementTextView.attributedText = attributedKiyaku
    }
    
    func initTitleLabel() {
        titleLabel.text = coupon?.name
        var textColor: UIColor!
        var discountTxt = ""
        var singleLinedTxt = ""
        if coupon?.service_type == 0 {
            discountTxt = "-\(String(coupon!.discount!))円 "
            singleLinedTxt = "定価\(String(coupon!.price!))円"
        } else if coupon?.service_type == 1{
            discountTxt = "無料 "
            singleLinedTxt = "定価\(String(coupon!.price!))円"
        } else {
            if coupon?.discount_type == 1 {
                discountTxt = "-\(String(coupon!.discount!))% "
            } else {
                discountTxt = "-\(String(coupon!.discount!))円 "
            }
            singleLinedTxt = ""
        }
        
        if coupon?.discount_type == 0 {
            if (coupon?.discount)! >= 500 {
                textColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
            } else if (coupon?.discount)! >= 50 {
                textColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
            } else {
                textColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
            }
        } else {
            if (coupon?.discount)! >= 15 {
                textColor = #colorLiteral(red: 0.9098039216, green: 0.1843137255, blue: 0.0862745098, alpha: 1)
            } else if (coupon?.discount)! >= 10 {
                textColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
            } else {
                textColor = #colorLiteral(red: 1, green: 0.6666666667, blue: 0.03921568627, alpha: 1)
            }
        }
        
        let discountAttr: [NSAttributedString.Key : Any] = [
            .font : UIFont(name: "NotoSansJP-Bold", size: 47.0)!,
            .foregroundColor: textColor!
        ]
        let singleLinedAttr: [NSAttributedString.Key : Any] = [
            .font : UIFont(name: "NotoSansJP-Bold", size: 18.0)!,
            .foregroundColor: #colorLiteral(red: 0.4941176471, green: 0.4941176471, blue: 0.4941176471, alpha: 1),
            .strikethroughStyle: 1
        ]
        let discountTxtAttr = NSMutableAttributedString(attributedString: NSAttributedString(string: discountTxt, attributes: discountAttr))
        discountTxtAttr.append(NSMutableAttributedString(string: singleLinedTxt, attributes: singleLinedAttr))
        discountLabel.attributedText = discountTxtAttr
        
        titleLabel.textColor = textColor
        firstTimeLabel.backgroundColor = textColor!
        telReserveLabel.backgroundColor = textColor!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        usedSwicth = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadHistory()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.title = "クーポンを使う"
        self.navigationItem.title = "クーポンを使う"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
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
            manager.requestWhenInUseAuthorization()
            break
        }
    }
    
    func loadHistory() {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let shopId = UserDefaults.standard.integer(forKey: "storeId")
        let searchUrl = "\(baseUrl)/check/\(String(shopId))/\(String(userId!))"
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
                    historyDatum = try decoder.decode(HistoryDatum.self, from: data)
                    if historyDatum != nil {
                        if ((historyDatum?.today) != nil) {
                            if (historyDatum?.today!.count)! > 0 {
                                let alert: UIAlertController = UIAlertController(title: "1店舗で1日1つのクーポンのみ利用可能です。", message: "", preferredStyle:  UIAlertController.Style.alert)
                                let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                    (action: UIAlertAction!) -> Void in
                                    self.navigationController?.popViewController(animated: true)
                                })
                                alert.addAction(confirmAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        if coupon?.first_time_discount == 1 {
                            if ((historyDatum?.history) != nil){
                                if (historyDatum?.history!.count)! > 0 {
                                    let alert: UIAlertController = UIAlertController(title: "初回限定クーポンです", message: "一度利用した店舗での利用はできません。", preferredStyle:  UIAlertController.Style.alert)
                                    let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                        (action: UIAlertAction!) -> Void in
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                    alert.addAction(confirmAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                } catch let error {
                    print("error decode json \(error)")
                }
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
        }
    }
    
    func createPickerView() {
        pickerView.delegate = self
        howManyTextField.inputView = pickerView
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButtonItem], animated: true)
        howManyTextField.inputAccessoryView = toolbar
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if peopleData[row] == 10 {
            return String("\(peopleData[row])名以上")
        }
        else {
            return String(peopleData[row])
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        howManyTextField.text = String(peopleData[row])
        people = peopleData[row]
        if howManyTextField.text != "" {
            useButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            useButton.isEnabled = true
        } else {
            useButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 0.5)
            useButton.isEnabled = false
        }
    }
    
    @objc func donePicker() {
        if howManyTextField.text != "" {
            useButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            useButton.isEnabled = true
        }
        howManyTextField.endEditing(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLoc = manager.location
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if howManyTextField.text != "" {
            useButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            useButton.isEnabled = true
        }
        howManyTextField.endEditing(true)
    }
    
    @IBAction func useButtonTapped(_ sender: Any) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("permitted")
        case .notDetermined:
            print("許可を求める")
        case .denied:
            print("拒否")
            let alert: UIAlertController = UIAlertController(title: "クーポンを利用する際、カメラの利用を許可していただく必要があります。", message: "カメラをオンにして店舗にあるQRコードを読み込んでください。", preferredStyle:  UIAlertController.Style.alert)
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
        case .restricted:
            let alert: UIAlertController = UIAlertController(title: "クーポンの利用する際、カメラの利用を許可していただく必要があります。", message: "設定画面でカメラをオンにして店舗にあるQRコードを読み込んでください。", preferredStyle:  UIAlertController.Style.alert)
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
        default: break
        }
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            useCouponView.isHidden = false
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = videoFrameView.layer.bounds
            videoPreviewLayer?.cornerRadius = 10
            videoFrameView.layer.addSublayer(videoPreviewLayer!)
            self.captureSession.startRunning()
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        } catch {
            print(error)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            str = "No QR code is detected"
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            if metadataObj.stringValue != nil {
                str = metadataObj.stringValue
                now = Date()
                let nowTime = Calendar.current.dateComponents([.hour], from: now)
                let time = nowTime.hour
                let shopId = UserDefaults.standard.integer(forKey: "storeId")
                let url = "\(baseCouponUrl)/coupon/\(shopId)"
                var timeId = self.coupon?.time_id
                if timeId! >= 24 {
                    timeId = timeId! - 24
                }
                if str != nil {
                    if self.str!.contains(url) && timeId == time {
                        var location: CLLocation?
                        CLGeocoder().geocodeAddressString(store!.address) { placemarks, error in
                            location = placemarks?.first?.location
                            if self.userLoc == nil {
                                let alert: UIAlertController = UIAlertController(title: "クーポンの読み込みには位置情報が必要です。", message: "設定画面で位置情報をオンにして再度QRコードを読み込んでください。", preferredStyle:  UIAlertController.Style.alert)
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
                            } else {
                                let distance = location?.distance(from: self.userLoc!)
                                if distance ?? 51 <= 50 {
                                    self.captureSession.stopRunning()
                                    self.qrCodeFrameView!.removeFromSuperview()
                                    self.videoPreviewLayer?.removeFromSuperlayer()
                                    self.useButton.isEnabled = false
                                    self.activityIndicatorView.startAnimating()
                                    if self.usedSwicth == 0 {
                                        self.usedSwicth = 1
                                        DispatchQueue.global(qos: .default).async {
                                            Thread.sleep(forTimeInterval: 1)
                                            DispatchQueue.main.async {
                                                self.api.useCoupon(params: [
                                                    "coupon_id": String(self.coupon!.coupon_id!),
                                                    "time": String(time!),
                                                    "people": self.howManyTextField.text!,
                                                    "bill_type": String((self.coupon?.bill_type)!),
                                                    "name": self.coupon!.name!,
                                                    "service_id": String(self.coupon!.id!),
                                                    "service_type" : String(self.coupon!.service_type!),
                                                    "price": String(self.coupon!.price ?? 0),
                                                    "discount": String(self.coupon!.discount!),
                                                    "discount_type": String(self.coupon!.discount_type!)
                                                ])
                                                { (json) in
                                                    if (json["errors"].exists()){
                                                        print("we have some errors -- usecoupon")
                                                        self.activityIndicatorView.stopAnimating()
                                                        self.useButton.isEnabled = true
                                                        return
                                                    }
                                                    self.activityIndicatorView.stopAnimating()
                                                    let soundURL = Bundle.main.url(forResource: "use_coupon", withExtension: "mp3")
                                                    do {
                                                        // 効果音を鳴らす
                                                        self.player = try AVAudioPlayer(contentsOf: soundURL!)
                                                        self.player?.play()
                                                    } catch {
                                                        print("error...")
                                                    }
//                                                    self.useCouponView.isHidden = true
                                                    self.thankFrameView.isHidden = false
                                                    self.useButton.isEnabled = true
                                                    let tabBarItem = self.tabBarController?.viewControllers?[1].tabBarItem
                                                    tabBarItem?.badgeValue = "●"
                                                    tabBarItem?.badgeColor = .clear
                                                    tabBarItem?.setBadgeTextAttributes(
                                                        [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1), NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 8.0)!], for: .normal
                                                    )
                                                    return
                                                }
                                            }
                                        }
                                    }
                                    
                                } else if distance ?? 51 > 50 {
                                    let alert: UIAlertController = UIAlertController(title: "店舗内のみでご利用いただけます。", message: "店舗に訪れて注文時に店舗内のQRコードを読み込んでください。", preferredStyle:  UIAlertController.Style.alert)
                                    let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                        (action: UIAlertAction!) -> Void in
                                    })
                                    alert.addAction(confirmAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    } else if self.str!.contains(url) == false {
                        let alert: UIAlertController = UIAlertController(title: "QRコードが正しくありません。", message: "正しいQRコードを読み込んでください。", preferredStyle:  UIAlertController.Style.alert)
                        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            (action: UIAlertAction!) -> Void in
                        })
                        alert.addAction(confirmAction)
                        present(alert, animated: true, completion: nil)
                    } else if timeId != time {
                        let alert: UIAlertController = UIAlertController(title: "クーポンの規定時間が正しくありません。", message: "現在ご利用いただけるのは\(time!)時〜のクーポンのみです。", preferredStyle:  UIAlertController.Style.alert)
                        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            (action: UIAlertAction!) -> Void in
                        })
                        alert.addAction(confirmAction)
                        present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func setCouponSubOptions() {
        if coupon?.first_time_discount == 1 && coupon?.telephone_reservation == 1 {
            firstTimeLabel.isHidden = false
            telReserveLabel.isHidden = false
            firstTimeLabel.text = "初回限定"
            telReserveLabel.text = "要電話予約"
        } else if coupon?.first_time_discount == 1 {
            firstTimeLabel.isHidden = false
            telReserveLabel.isHidden = true
            firstTimeLabel.text = "初回限定"
        } else if coupon?.telephone_reservation == 1 {
            firstTimeLabel.isHidden = false
            telReserveLabel.isHidden = true
            firstTimeLabel.text = "要電話予約"
        } else {
            firstTimeLabel.isHidden = true
            telReserveLabel.isHidden = true
        }
        firstTimeLabel.layer.masksToBounds = true
        telReserveLabel.layer.masksToBounds = true
        firstTimeLabel.layer.cornerRadius = 4
        telReserveLabel.layer.cornerRadius = 4
        var fixedfirstFrame = firstTimeLabel.frame
        firstTimeLabel.sizeToFit()
        fixedfirstFrame.size.height = firstTimeLabel.frame.size.height
        firstTimeLabel.frame = fixedfirstFrame
        
        var fixedTelFrame = telReserveLabel.frame
        telReserveLabel.sizeToFit()
        fixedTelFrame.size.height = telReserveLabel.frame.size.height
        telReserveLabel.frame = fixedTelFrame
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        print("Ad wasn't ready")
        
    }
}
