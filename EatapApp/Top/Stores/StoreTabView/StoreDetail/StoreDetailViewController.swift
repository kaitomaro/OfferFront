//
//  StoreDetailViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2020/12/29.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftKeychainWrapper



class StoreDetailViewController: UIViewController , IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,UITextViewDelegate {

    let semaphore = DispatchSemaphore(value: 0)
    private var storeModel: StoreModel?
    private var time1Model: [TimeModel]?
    private var time2Model: [TimeModel]?
    private var detailDatum: DetailDatum?
    
    var itemInfo: IndicatorInfo = "店舗情報"
    var introSentence:String = ""
    var phoneNumber:String = ""
    var adress: String = ""
    var id: Int!

    let baseUrl = Configuration.shared.apiUrl
    
    @IBOutlet weak var detailTableView: UITableView!
    var viewPositionY: CGFloat?
    var userInfo: [String: Any] = [
        "offsety": CGFloat(),
        "state": 0
    ]
    
    var snsSentence = ""
    var facebookTxt = ""
    var instragramTxt = ""
    var twitterTxt = ""
    var snsTxt = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.delegate = self
        detailTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 400, right: 0)
        id = UserDefaults.standard.integer(forKey: "storeId")
        loadStore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        NotificationCenter.default.addObserver(self,selector: #selector(self.feedScrollMove),name: .notifyMainScroll ,object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if UserDefaults.standard.integer(forKey: "childscroll") == 1 {
            detailTableView.isScrollEnabled = true
        } else {
            detailTableView.isScrollEnabled = false
        }
    }
    
    
    func loadStore() {
        
        let searchUrl = "\(baseUrl)/shop/detail/\(String(id!))"
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
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
                print(data)
                do {
                    self.detailDatum = try JSONDecoder().decode(DetailDatum.self, from: data)
                    time1Model = detailDatum?.time1
                    time2Model = detailDatum?.time2
                    storeModel = detailDatum?.store
                } catch let error {
                    print("error decode json \(error)")
                }
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
            detailTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IntroductionCell") as? IntroductionCell
            if storeModel?.sentence != nil {
                cell?.contentView.translatesAutoresizingMaskIntoConstraints = true
                cell?.introLabel.numberOfLines = 0
                cell?.titleLabel.text = "お店のPR"
                cell?.introLabel.text = storeModel?.sentence
            }
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TelCell") as? TelCell
            if storeModel?.phone != nil {
                cell?.telLabel.text = "TEL"
                cell?.numberLabel.text = storeModel?.phone
            }
            return cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell") as? AddressCell
            if storeModel?.address != nil {
                cell?.titleLabel.text = "住所"
                cell?.addressLabel.text = storeModel?.address
            }
            return cell!
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OpeningHoursCell") as? OpeningHoursCell
            var timeTxt = "【"
            if time1Model != nil {
                cell?.titleLabel.text = "営業時間"
                if time1Model![0].monday == 1 {
                    timeTxt = timeTxt + "月"
                }
                if time1Model![0].tsuesday == 1 {
                    timeTxt = timeTxt + "火"
                }
                if time1Model![0].wednesday == 1 {
                    timeTxt = timeTxt + "水"
                }
                if time1Model![0].thursday == 1 {
                    timeTxt = timeTxt + "木"
                }
                if time1Model![0].friday == 1 {
                    timeTxt = timeTxt + "金"
                }
                if time1Model![0].saturday == 1 {
                    timeTxt = timeTxt + "土"
                }
                if time1Model![0].sunday == 1 {
                    timeTxt = timeTxt + "日"
                }
                timeTxt = timeTxt + "】"
                timeTxt = timeTxt + " "
                if time1Model?.count == 2 {
                    timeTxt = timeTxt + "\n " + time1Model![0].start_time + "〜" + time1Model![0].end_time + "," + time1Model![1].start_time + "〜" + time1Model![1].end_time
                } else {
                    timeTxt = timeTxt + "\n " + time1Model![0].start_time + "〜" + time1Model![0].end_time
                }
                
                if time2Model != nil {
                    if time2Model?.count != 0 {
                        timeTxt = timeTxt + "\n" + "【"
                        if time2Model![0].monday! != 0 {
                            timeTxt = timeTxt + "月"
                        }
                        if time2Model![0].tsuesday! != 0 {
                            timeTxt = timeTxt + "火"
                        }
                        if time2Model![0].wednesday! != 0 {
                            timeTxt = timeTxt + "水"
                        }
                        if time2Model![0].thursday! != 0 {
                            timeTxt = timeTxt + "木"
                        }
                        if time2Model![0].friday! != 0 {
                            timeTxt = timeTxt + "金"
                        }
                        if time2Model![0].saturday != 0 {
                            timeTxt = timeTxt + "土"
                        }
                        if time2Model![0].sunday != 0 {
                            timeTxt = timeTxt + "日"
                        }
                        timeTxt = timeTxt + "】"
                        if time2Model?.count == 2 {
                            timeTxt = timeTxt + "\n " + time2Model![0].start_time + "〜" + time2Model![0].end_time + "," + time2Model![1].start_time + "〜" + time2Model![1].end_time
                        } else {
                            timeTxt = timeTxt + "\n " + time2Model![0].start_time + "〜" + time2Model![0].end_time
                        }
                    }
                    
                }
                cell?.timeLabel1.font = UIFont(name: "HiraginoSans-W3", size: 15)!
                cell?.timeLabel1.textColor = UIColor(displayP3Red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
                cell?.timeLabel1.text = timeTxt
            }
            return cell!
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreTablesCell") as? StoreTablesCell
            if storeModel?.number_of_seats != nil {
                cell?.titleLabel.text = "席数"
                cell?.seatAmountLabel.text = "\(storeModel!.number_of_seats!)席"
            }
            return cell!
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodCell") as? PaymentMethodCell
            if storeModel?.payment_options != nil {
                cell?.titleLabel.text = "決済方法"
                cell?.PayMethodLabel.text = storeModel?.payment_options
            }
            return cell!
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomePageCell") as? HomePageCell
            if storeModel != nil {
                cell?.titleLabel.text = "店舗HP"
                if storeModel?.hp != nil {
                    cell?.urlLabel.text = storeModel?.hp!
                }
            }
            return cell!
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SnsCell") as? SnsCell
            if storeModel != nil {
                cell?.titleLabel.text = "店舗SNS"
                
                if storeModel?.facebook != nil {
                    snsSentence = snsSentence + "Facebook "
                    facebookTxt = "Facebook "
                }
                
                if storeModel?.instagram != nil {
                    if snsSentence != "" {
                        snsSentence = snsSentence + "\nInstagram "

                    } else {
                        snsSentence = snsSentence + "Instagram "
                    }
                    instragramTxt = "Instagram "
                }
                
                if storeModel?.twitter != nil {
                    if snsSentence != "" {
                        snsSentence = snsSentence + "\nTwitter "
                    } else {
                        snsSentence = snsSentence + "Twitter "
                    }
                    twitterTxt = "Twitter "
                }
                
                if storeModel?.sns != nil {
                    if snsSentence != "" {
                        snsSentence = snsSentence + "\n" + storeModel!.sns! + " "
                    } else {
                        snsSentence = snsSentence + storeModel!.sns! + " "
                    }
                    snsTxt = storeModel!.sns! + " "
                }
                cell?.snsLinkTextView.isSelectable = true
                cell?.snsLinkTextView.isEditable = false
                cell?.snsLinkTextView.delegate = self
                let attributedString = NSMutableAttributedString(string: snsSentence)
                let holeRange = NSString(string: snsSentence).range(of: snsSentence)
                attributedString.addAttributes([.baselineOffset: 7], range: holeRange)
                let facebookRange = NSString(string: snsSentence).range(of: facebookTxt)
                let instagramRange = NSString(string: snsSentence).range(of: instragramTxt)
                let twitterRange = NSString(string: snsSentence).range(of: twitterTxt)
                let snsRange = NSString(string: snsSentence).range(of: snsTxt)
                if storeModel?.facebook != nil {
                    attributedString.addAttributes(
                        [
                            .link: storeModel!.facebook!,
                            .underlineStyle: NSUnderlineStyle.single.rawValue,
                            .font: UIFont(name: "NotoSansJP-Regular", size: 14)!,
                            .paragraphStyle: NSMutableParagraphStyle()
                        ],
                        range: facebookRange
                    )
                }
                
                if storeModel?.instagram != nil {
                    attributedString.addAttributes(
                        [
                            .link: storeModel!.instagram!,
                            .underlineStyle: NSUnderlineStyle.single.rawValue,
                            .font: UIFont(name: "NotoSansJP-Regular", size: 14)!,
                            .paragraphStyle: NSMutableParagraphStyle()
                        ],
                        range: instagramRange
                    )
                }
                
                if storeModel?.twitter != nil {
                    attributedString.addAttributes(
                        [
                            .link: storeModel!.twitter!,
                            .underlineStyle: NSUnderlineStyle.single.rawValue,
                            .font: UIFont(name: "NotoSansJP-Regular", size: 14)!,
                            .paragraphStyle: NSMutableParagraphStyle()
                        ],
                        range: twitterRange
                    )
                }
                
                if storeModel?.sns != nil {
                    attributedString.addAttributes(
                        [
                            .link: storeModel!.sns!,
                            .underlineStyle: NSUnderlineStyle.single.rawValue,
                            .font: UIFont(name: "NotoSansJP-Regular", size: 14)!,
                            .paragraphStyle: NSMutableParagraphStyle()
                        ],
                        range: snsRange
                    )
                }
                
                
                cell?.snsLinkTextView.attributedText = attributedString
                
            }
            return cell!
        default:
            return UITableViewCell()
        }
    }
    
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {

        UIApplication.shared.open(URL)

        return false
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == detailTableView {
            var userInfo: [String: Any] = [
                "offsety": scrollView.contentOffset.y
            ]
            
            if scrollView.contentOffset.y <= 0 {
                print(scrollView.contentOffset)
                if scrollView.contentOffset.y < -310 {
                    scrollView.contentOffset.y = -310
                    userInfo["offsety"] = -310
                }
                
                NotificationCenter.default.post(name: .notifyScroll, object: nil,userInfo:userInfo)
                UserDefaults.standard.setValue(0 , forKey: "childscroll")
                detailTableView.isScrollEnabled = false
            }
        }
    }
    
    @objc func feedScrollMove(notification: NSNotification) {
        let posisionY:CGFloat = notification.userInfo?["offsety"] as? CGFloat ?? 0
        print(posisionY)
        detailTableView.isScrollEnabled = true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 6 {
            if storeModel?.hp != nil {
                let url = NSURL(string: (storeModel?.hp)!)
                if UIApplication.shared.canOpenURL(url! as URL){
                    UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
