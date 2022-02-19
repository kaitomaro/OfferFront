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
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var causionLabel: UILabel!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var statementTextView: UITextView!
    @IBOutlet weak var howManyLabel: UILabel!
    @IBOutlet weak var howManyTextField: UITextField!
    @IBOutlet weak var thankView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var thanksLabel: UILabel!
    
    struct HistoryModel: Codable {
        var user_id: Int?
        var shop_id: Int?
        var created_at: String?
    }
    
    struct HistoryDatum: Codable {
        var history: [HistoryModel]?
        var today: [HistoryModel]?
    }
    
    var myLocationManager:CLLocationManager!
    var coupon: CouponModel?
    var store: StoreModel?
    var todayModel: [HistoryModel]?
    var historyModel: [HistoryModel]?
    var historyDatum: HistoryDatum?
    
    var str: String?
    let captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var pickerView = UIPickerView()
    var peopleData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var people: Int?
    var now = Date()
    var api = API()
    var activityIndicatorView = UIActivityIndicatorView()

    var userLoc: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        titleLabel.text = coupon?.name
        titleLabel.textColor = UIColor(displayP3Red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        setCouponSubOptions()
        useButton.layer.cornerRadius = 10
        createPickerView()
        let titleAttr: [NSAttributedString.Key : Any] = [
            .font : UIFont(name: "HiraginoSans-W3", size: 16)!,
            .foregroundColor :UIColor(displayP3Red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        ]
        let attr1 = NSAttributedString(string: "クーポン割引 ", attributes: titleAttr)
        let discountText = NSMutableAttributedString(attributedString: attr1)
        let discountAttr: [NSAttributedString.Key : Any] = [
            .font : UIFont(name: "HelveticaNeue-Bold", size: 30)!,
            .foregroundColor :UIColor(displayP3Red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        ]
        let attr2 = NSMutableAttributedString(string: "\(coupon!.discount!)", attributes: discountAttr)
        discountText.append(attr2)
        var attr3 = NSMutableAttributedString()
        if coupon?.discount_type == 1 {
            attr3 = NSMutableAttributedString(string: " %", attributes: titleAttr)
        } else {
            attr3 = NSMutableAttributedString(string: " 円", attributes: titleAttr)
        }
        discountText.append(attr3)
        discountLabel.attributedText = discountText
        middleView.layer.borderWidth = 0.5
        middleView.layer.borderColor = UIColor(displayP3Red: 89/255, green: 89/255, blue: 89/255, alpha: 1).cgColor
        middleView.layer.shadowColor = UIColor.black.cgColor
        thankView.layer.borderColor = #colorLiteral(red: 0.5309594274, green: 0.8110739589, blue: 0.2307085991, alpha: 1).cgColor
        thankView.layer.borderWidth = 1
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: thankView.frame.width, height: 15)
        border.backgroundColor = #colorLiteral(red: 0.5309594274, green: 0.8110739589, blue: 0.2307085991, alpha: 1).cgColor
        thankView.layer.addSublayer(border)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.5309594274, green: 0.8110739589, blue: 0.2307085991, alpha: 1)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.title = store?.name
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
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
        let baseUrl = "https://www.eatap.co.jp/api"
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
            switch response.result {
            case .success:
                
                guard let data = response.data else { return }
                print(response.value)
                do {
                    let decoder = JSONDecoder()
                    historyDatum = try decoder.decode(HistoryDatum.self, from: data)
                    print(historyDatum)
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
            useButton.backgroundColor = #colorLiteral(red: 0.5733121037, green: 0.8155091405, blue: 0.3133224845, alpha: 1)
            useButton.isEnabled = true
        } else {
            useButton.backgroundColor = #colorLiteral(red: 0.5733121037, green: 0.8155091405, blue: 0.3133224845, alpha: 0.5)
            useButton.isEnabled = false
        }
    }
    
    @objc func donePicker() {
        if howManyTextField.text != "" {
            useButton.backgroundColor = #colorLiteral(red: 0.5733121037, green: 0.8155091405, blue: 0.3133224845, alpha: 1)
            useButton.isEnabled = true
        }
        howManyTextField.endEditing(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLoc = manager.location
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if howManyTextField.text != "" {
            useButton.backgroundColor = #colorLiteral(red: 0.5733121037, green: 0.8155091405, blue: 0.3133224845, alpha: 1)
            useButton.isEnabled = true
        }
        howManyTextField.endEditing(true)
    }
    
    @IBAction func useButtonTapped(_ sender: Any) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
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
                let url = "https://www.eatap.co.jp/coupon/\(shopId)"
                var timeId = self.coupon?.time_id
                if timeId! >= 24 {
                    timeId = timeId! - 24
                }
                if str != nil {
                    self.activityIndicatorView.startAnimating()
                    if self.str!.contains(url) && timeId == time {
                        var location: CLLocation?
                        CLGeocoder().geocodeAddressString(store!.address) { placemarks, error in
                            location = placemarks?.first?.location
                            if self.userLoc == nil {
                               let alert: UIAlertController = UIAlertController(title: "アプリの位置情報サービスを\nオンにして下さい。", message: "", preferredStyle:  UIAlertController.Style.alert)
                               let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                   (action: UIAlertAction!) -> Void in
                                self.activityIndicatorView.stopAnimating()
                               })
                               alert.addAction(confirmAction)
                               self.present(alert, animated: true, completion: nil)
                            } else {
                                let distance = location?.distance(from: self.userLoc!)
                                if distance! <= 30 {
                                    self.captureSession.stopRunning()
                                    self.qrCodeFrameView!.removeFromSuperview()
                                    self.videoPreviewLayer?.removeFromSuperlayer()
                                    
                                    DispatchQueue.global(qos: .default).async {
                                        Thread.sleep(forTimeInterval: 3)
                                        DispatchQueue.main.async {
                                            self.api.useCoupon(params: ["coupon_id": String(self.coupon!.coupon_id!), "time": String(time!), "people": self.howManyTextField.text!, "bill_type": String((self.coupon?.bill_type)!)])
                                            { (json) in
                                                if (json["errors"].exists()){
                                                    print("we have some errors -- usecoupon")
                                                    self.activityIndicatorView.stopAnimating()
                                                    return
                                                }
                                                
                                                self.thankView.isHidden = false
                                                self.activityIndicatorView.stopAnimating()
                                                return
                                            }
                                        }
                                    }
                                } else if distance! > 300000000000000 {
                                    let alert: UIAlertController = UIAlertController(title: "店舗内のみでご利用いただけます。", message: "店舗に訪れて注文時に店舗内のQRコードを読み込んでください。", preferredStyle:  UIAlertController.Style.alert)
                                    let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                        (action: UIAlertAction!) -> Void in
                                        self.activityIndicatorView.stopAnimating()
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
                            self.activityIndicatorView.stopAnimating()

                        })
                        alert.addAction(confirmAction)
                        present(alert, animated: true, completion: nil)
                    } else if timeId != time {
                        let alert: UIAlertController = UIAlertController(title: "クーポンの規定時間が正しくありません。", message: "現在ご利用いただけるのは\(time!)時〜のクーポンのみです。", preferredStyle:  UIAlertController.Style.alert)
                        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            (action: UIAlertAction!) -> Void in
                            self.activityIndicatorView.stopAnimating()

                        })
                        alert.addAction(confirmAction)
                        present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func setCouponSubOptions() {
        firstTimeLabel.layer.cornerRadius = 5
        firstTimeLabel.layer.borderWidth = 1
        firstTimeLabel.layer.borderColor = UIColor(displayP3Red: 89/255, green: 89/255, blue: 89/255, alpha: 1).cgColor
        firstTimeLabel.textColor = UIColor(displayP3Red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        telReserveLabel.layer.cornerRadius = 5
        telReserveLabel.layer.borderWidth = 1
        telReserveLabel.layer.borderColor = UIColor(displayP3Red: 89/255, green: 89/255, blue: 89/255, alpha: 1).cgColor
        telReserveLabel.textColor = UIColor(displayP3Red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
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
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
