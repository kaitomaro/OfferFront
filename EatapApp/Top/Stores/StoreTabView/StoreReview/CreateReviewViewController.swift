//
//  CreateReviewViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/01/22.
//

import UIKit
import Cosmos
import Alamofire
import SwiftKeychainWrapper

class CreateReviewViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var reviewTextView: PlaceHolderTextView!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var thankView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var thankFrameView: UIView!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var starFrameView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starTitleView: UILabel!
    @IBOutlet weak var starAmountLabel: UILabel!
    @IBOutlet weak var reviewBodyTitleLabel: UILabel!
    
    
    var navTitle: String!
    var doneButtonItem: UIBarButtonItem!
    var starRate: Double = 3.0
    var api = API()

    let baseUrl = Configuration.shared.apiUrl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTextView.placeHolder = "お店はいかがでしたか？"
        scrollView.delegate = self
        reviewTextView.delegate = self
        getUserInfo()
        thankView.layer.cornerRadius = 8
        reviewTextView.layer.cornerRadius = 8
        starFrameView.layer.cornerRadius = 8
        cosmosView.didTouchCosmos = { rating in
            self.starRate = rating
            self.starAmountLabel.text = String(rating)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        self.navigationItem.title = navTitle
        cosmosView.settings.fillMode = .full
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reviewTextView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.title = "レビューを投稿"

        doneButtonItem = UIBarButtonItem(title: "投稿", style: .done, target: self, action:  #selector(reviewButtonTapped(_:)))
        doneButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 14.0)!], for: .normal)
        doneButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 14.0)!], for: .disabled)
        doneButtonItem.isEnabled = false
        doneButtonItem.tintColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
        self.navigationItem.rightBarButtonItem = doneButtonItem
    }
    
    func getUserInfo() {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        
        let searchUrl = "\(baseUrl)/user/\(userId!)"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(
            searchUrl,
            method: .get,
            parameters: ["user_id": userId!],
            encoding: URLEncoding(destination: .queryString),
            headers: headers
        ).responseJSON{ response in
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
                    let userModel = try decoder.decode(UserModel.self, from: data)
                } catch let error {
                        print("error decode json \(error)")
                }
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
        }
    }
    
    @objc func reviewButtonTapped(_ sender: UIBarButtonItem) {
        self.doneButtonItem.isEnabled = false
        api.createReview(params: [
            "rate": String(starRate),
            "sentence": reviewTextView.text!
        ])
        { (json) in
            if (json["errors"].exists()){
                print("we have some errors")
                return
            }
            self.reviewTextView.endEditing(true)
            self.thankFrameView.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {

        if textView.text.isEmpty {
            doneButtonItem.isEnabled = false
        } else {
            doneButtonItem.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("koko")
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc private func showKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
            
        }
        guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardSize = keyboardInfo.cgRectValue.size
        scrollView.layoutIfNeeded()
        contentView.layoutIfNeeded()
        reviewTextView.layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: self.view.frame.size.height - keyboardSize.height - 100)
        ])
        contentView.frame.size.height = self.view.frame.size.height - keyboardSize.height - 100
        scrollView.contentSize.height = self.view.frame.size.height - keyboardSize.height - 100
        NSLayoutConstraint.activate([
            reviewTextView.heightAnchor.constraint(equalToConstant: self.view.frame.size.height - keyboardSize.height - 300)
        ])
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
