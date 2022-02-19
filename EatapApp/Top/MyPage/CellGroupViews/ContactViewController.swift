//
//  ContactViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit
import Cosmos
import Alamofire
import SwiftKeychainWrapper

class ContactViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var contactTextView: PlaceHolderTextView!
    @IBOutlet weak var thankView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var thankBackView: UIView!
    
    var doneButtonItem: UIBarButtonItem!
    var api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactTextView.placeHolder = "ご自由にお問い合わせください。"
        contactTextView.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: self.view.frame.height - 80)
        thankView.layer.cornerRadius = 8
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        contactTextView.layer.cornerRadius = 23
        contactTextView.delegate = self
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        doneButtonItem = UIBarButtonItem(title: "送信", style: .done, target: self, action:  #selector(contactButtonTapped(_:)))
        doneButtonItem.isEnabled = false
        doneButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 14.0)!], for: .normal)
        doneButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Regular", size: 14.0)!], for: .disabled)
        doneButtonItem.tintColor = #colorLiteral(red: 0.1450980392, green: 0.4274509804, blue: 0.9568627451, alpha: 0.5)
        self.navigationItem.rightBarButtonItem = doneButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        self.tabBarController?.tabBar.isHidden = true
        contactTextView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = "お問い合わせ"
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
    
    @objc func contactButtonTapped(_ sender: UIBarButtonItem) {
        self.doneButtonItem.isEnabled = false
        doneButtonItem.tintColor = #colorLiteral(red: 0.1450980392, green: 0.4274509804, blue: 0.9568627451, alpha: 0.5)
        api.contact(params: ["sentence": contactTextView.text!])
        { (json) in
            if (json["errors"].exists()){
                print("we have some errors -- usecoupon")
                return
            }
            self.contactTextView.endEditing(true)
            self.thankBackView.isHidden = false
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
        contactTextView.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: self.view.frame.height - keyboardSize.height - 120)
    }

    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text.suffix(1)
        if textView.textColor == #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 0.5) {
            textView.text = nil
            textView.textColor = #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
            doneButtonItem.isEnabled = true
            doneButtonItem.tintColor = #colorLiteral(red: 0.1450980392, green: 0.4274509804, blue: 0.9568627451, alpha: 1)
            textView.text = String(str)
        }
        if textView.text.isEmpty {
            doneButtonItem.isEnabled = false
        } else {
            doneButtonItem.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
