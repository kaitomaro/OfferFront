//
//  PointViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/06/12.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import AVFoundation


class PointViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lotoBackgroundView: UIImageView!
    @IBOutlet weak var lotoButton: UIButton!
    @IBOutlet weak var lotoCountLabel: UILabel!
    @IBOutlet weak var causionTextView: UITextView!
    @IBOutlet weak var lotoResultView: UIView!
    @IBOutlet weak var lotoImageView: UIImageView!
    @IBOutlet weak var lotoCloseButton: UIButton!
    @IBOutlet weak var winView: UIView!
    @IBOutlet weak var AmountOfMoneyLabel: UILabel!
    @IBOutlet weak var gotGiftLabel: UILabel!
    @IBOutlet weak var loseView: UIView!
    @IBOutlet weak var loseLabel: UILabel!
    @IBOutlet weak var resultImageFrameView: UIView!
    
    var lotoInt = 0
    var activityIndicatorView = UIActivityIndicatorView()
    var api = API()
    var amount: Int?
    let baseUrl = Configuration.shared.apiUrl
    var player:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCausionText()
        lotoButton.layer.cornerRadius = 23
        resultImageFrameView.layer.cornerRadius = 10
        lotoImageView.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        if token != nil && userId != nil {
            getAmountOfLotos()
        } else {
            let alert = UIAlertController(title: "ログイン画面へ", message: "クーポンくじの利用にはログインする必要があります", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                self.tabBarController?.selectedIndex = 0
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
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func getAmountOfLotos(){
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let searchUrl = "\(baseUrl)/lotos/\(String(userId!))"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(
            searchUrl,
            method: .get,
            parameters: ["": ""],
            encoding: URLEncoding(destination: .queryString),
            headers: headers).responseJSON
            { [self] response in
            switch response.result {
            case .success:
                amount = response.value as? Int
                if amount != nil {
                    if amount! > 0 {
                        setLotoLabelText()
                        lotoButton.isEnabled = true
                        lotoButton.backgroundColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
                    } else {
                        lotoCountLabel.text = "くじが引けません"
                        lotoButton.isEnabled = false
                        lotoButton.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
                    }
                } else {
                    lotoCountLabel.text = "くじが引けません"
                    lotoButton.isEnabled = false
                    lotoButton.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
                }
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
        }
    }
    
    func setLotoLabelText() {
        lotoCountLabel.text = "あと" + " " + "\(String(describing: amount!))回 引けます"
        
        let sentence = lotoCountLabel!.text!
        let amountString = "\(String(describing: amount!))回 "
        let amountRange = (sentence as NSString).range(of: amountString)
        let attributedStr = NSMutableAttributedString(string: sentence)
        attributedStr.addAttributes(
            [
                NSAttributedString.Key.backgroundColor:UIColor.white
            ], range: amountRange
        )
        
        lotoCountLabel.attributedText = attributedStr
    }
    
    func setCausionText() {
        causionTextView.font = UIFont(name: "NotoSansJP-Regular", size: 10)
        causionTextView.text = "注意事項\n・くじ引き権利が付与される条件は、クーポン利用時にQRコードを読み込むことです。１利用につき、くじ引き権利を1つ付与します。\n・アプリ内で実施されるくじに関して、予告なく内容の変更、提供の中止または終了する場合がございます。\n・くじ引き権利が不正行為によって獲得されたと当社が判断した場合、事前の予告なく、保有するくじ引き権利全てを失効させ、アプリの利用を禁止します。\n・アプリ内で実施される各種くじは株式会社Eatapが主催しているものであり、Apple inc.、アップルジャパン合同会社、Google Inc.によるものではございません。"
        
        let sentence = causionTextView!.text!
        let titleString = "注意事項"
        let wholeRange = (sentence as NSString).range(of: sentence)
        let titleRange = (sentence as NSString).range(of: titleString)
        let attributedStr = NSMutableAttributedString(string: sentence)
        attributedStr.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 11.0)!,
                NSAttributedString.Key.baselineOffset: 11,
                NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
            ], range: wholeRange
        )
        
        attributedStr.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 15.0)!,
                NSAttributedString.Key.baselineOffset: 15,
                NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
            ], range: titleRange
        )
        
        causionTextView.attributedText = attributedStr
    }

    func setAmountOfMoney(amountOfMoney: String) {
        AmountOfMoneyLabel.text = "\(amountOfMoney)円分"
        let sentence = AmountOfMoneyLabel!.text!
        let amountString = amountOfMoney
        let yenString = "円分"
        let amountRange = (sentence as NSString).range(of: amountString)
        let yenRange = (sentence as NSString).range(of: yenString)
        let attributedTxt = NSMutableAttributedString(string: sentence)
        attributedTxt.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Bold", size: 29.0)!
            ], range: amountRange
        )
        attributedTxt.addAttributes(
            [
                NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Bold", size: 22.0)!
            ], range: yenRange
        )
        AmountOfMoneyLabel.attributedText = attributedTxt
    }
    
    @IBAction func tappedGiftButton(_ sender: Any) {
        lotoCloseButton.isEnabled = false
        activityIndicatorView.style = .large
        activityIndicatorView.center = view.center
        activityIndicatorView.color = .black
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        lotoResultView.isHidden = false
        let randomIntVal = Int.random(in: 1...6480)
        var money = 0
        var lotoImg = ""
        if randomIntVal == 1 {
            print("1等：2000円です")
            lotoInt = 1
            setAmountOfMoney(amountOfMoney: "2000")
            lotoImg = "win"
            money = 2000
        } else if randomIntVal <= 3 {
            lotoInt = 2
            print("2等：1000円です")
            setAmountOfMoney(amountOfMoney: "1000")
            lotoImg = "win"
            money = 1000
        } else if randomIntVal <= 6 {
            lotoInt = 3
            print("3等：300円です")
            setAmountOfMoney(amountOfMoney: "300")
            lotoImg = "win"
            money = 300
        } else if randomIntVal <= 70 {
            lotoInt = 4
            print("4等：50円です")
            setAmountOfMoney(amountOfMoney: "50")
            lotoImg = "win"
            money = 50
        } else if randomIntVal <= 286 {
            lotoInt = 5
            
            print("5等：20円です")
            setAmountOfMoney(amountOfMoney: "20")
            lotoImg = "win"
            money = 20
        } else {
            lotoInt = 0
            print("ハズレです")
            lotoImg = "lose"
            money = 0
        }
        
        DispatchQueue.global(qos: .default).async {
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.async {
                self.api.sendLotoResult(params: [
                    "kind_of_prize": String(self.lotoInt),
                    "amount_of_money": String(money)
                ]) { [self] (json) in
                    print(json)
                    self.activityIndicatorView.stopAnimating()
                    self.lotoImageView.image = UIImage(named: lotoImg)

                    if lotoInt != 0 {
                        let soundURL = Bundle.main.url(forResource: "hit", withExtension: "mp3")
                        do {
                            // 効果音を鳴らす
                            self.player = try AVAudioPlayer(contentsOf: soundURL!)
                            self.player?.play()
                        } catch {
                            print("error...")
                        }
                        
                        loseView.isHidden = true
                        winView.isHidden = false
                    } else {
                        let soundURL = Bundle.main.url(forResource: "lose", withExtension: "mp3")
                        do {
                            // 効果音を鳴らす
                            self.player = try AVAudioPlayer(contentsOf: soundURL!)
                            self.player?.play()
                        } catch {
                            print("error...")
                        }
                        winView.isHidden = true
                        loseView.isHidden = false
                    }
                    self.amount = self.amount! - 1
                    if self.amount! > 0 {
                        self.lotoButton.isEnabled = true
                        lotoButton.backgroundColor = #colorLiteral(red: 1, green: 0.4235294118, blue: 0, alpha: 1)
                        setLotoLabelText()
                        let tabBarItem = tabBarController?.viewControllers?[1].tabBarItem
                        tabBarItem?.badgeValue = "●"
                        tabBarItem?.badgeColor = .clear
                        tabBarItem?.setBadgeTextAttributes(
                            [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1), NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 8.0)!], for: .normal
                        )

                    } else {
                        self.lotoButton.isEnabled = false
                        lotoButton.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
                        lotoCountLabel.text = "くじが引けません"
                        let tabBarItem = tabBarController?.viewControllers?[1].tabBarItem
                        tabBarItem?.badgeValue = nil
                        tabBarItem?.badgeColor = .clear
                        tabBarItem?.setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
                    }
                    self.lotoCloseButton.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func tappedCloseButton(_ sender: Any) {
        lotoResultView.isHidden = true
        winView.isHidden = true
        loseView.isHidden = true
        self.view.backgroundColor = .white
        self.lotoImageView.image = UIImage()
        self.navigationController?.popViewController(animated: true)
    }
}
