//
//  LoginViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/03/24.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var loginLoadView: UIView!
    var activityIndicatorView = UIActivityIndicatorView()
    
    let api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor :#colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 0.7008064159)])
        emailField.layer.cornerRadius = 10
        emailField.layer.masksToBounds = true
        passField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor :#colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 0.7)])
        passField.layer.cornerRadius = 10
        passField.layer.masksToBounds = true
        loginLoadView.isHidden = true
        loginButton.isEnabled = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        loginButton.layer.cornerRadius = 23
        setTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let navigationBar = navigationController!.navigationBar
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        loginButton.isEnabled = false
        loginLoadView.isHidden = false
        activityIndicatorView.style = .large
        activityIndicatorView.center = view.center
        activityIndicatorView.color = .black
        loginLoadView.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        guard let email = emailField.text, let pass = passField.text else {
            print("please fill out fields")
            loginButton.isEnabled = true
            return
        }
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        var object:[String:Any] = ["user_id": 0, "token": ""]
        
        DispatchQueue.global(qos: .default).async {
            Thread.sleep(forTimeInterval: 2)
            DispatchQueue.main.async {
                self.api.login(params: ["email": email, "password": pass, "device_name": deviceId]) { (json) in
                    if (json["errors"].exists()){
                        print(json["errors"])
                        self.loginButton.isEnabled = true
                        self.alertLabel.isHidden = false
                        self.activityIndicatorView.stopAnimating()
                        self.loginLoadView.isHidden = true
                        self.alertLabel.text! = json["errors"].string!
                        if json["errors"].string! == "ユーザーが未登録です。登録の際に送ったメールリンクを開いてユーザー登録を完了させてください。" {
                            self.resendButton.isHidden = false
                        }
                        return
                    } else {
                        do {
                            object = json.object as! [String : Any]
                        } catch {
                            print(error)
                        }
                        
                        if (KeychainWrapper.standard.string(forKey: "tmp_token") != nil) {
                            KeychainWrapper.standard.removeObject(forKey: "tmp_token")
                        }
                        
                        if (KeychainWrapper.standard.string(forKey: "tmp_id") != nil) {
                            KeychainWrapper.standard.removeObject(forKey: "tmp_id")
                        }
                        
                        if object["token"] != nil && object["user_id"] != nil {
                            KeychainWrapper.standard.set(object["token"] as! String, forKey: "token")
                            KeychainWrapper.standard.set(object["user_id"] as! Int, forKey: "my_id")
                            if KeychainWrapper.standard.string(forKey: "token") != nil && KeychainWrapper.standard.integer(forKey: "my_id") != nil {
                                let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab")
                                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                            }
                        }
                        self.activityIndicatorView.stopAnimating()
                    }
                }

            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^([A-Z0-9a-z._+-])+@([A-Za-z0-9.-])+\\.([A-Za-z]{2,})$"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func tappedResend(_ sender: Any) {
        self.resendButton.isEnabled = false
        if emailField != nil && passField != nil {
            let deviceId = UIDevice.current.identifierForVendor!.uuidString
            api.resend(params: [
                "email": emailField.text!,
                "device_name": deviceId
            ])
            { (json) in
                if (json["errors"].exists()){
                    self.alertLabel.text = json["errors"].stringValue
                    self.resendButton.isHidden = true
                    return
                }
                var object:[String:Any] = ["user_id": 0, "token": ""]
                do {
                    object = json.object as! [String : Any]
                } catch {
                    print(error)
                }
                
                if object["token"] != nil && object["user_id"] != nil {
                    KeychainWrapper.standard.set(object["token"] as! String, forKey: "tmp_token")
                    KeychainWrapper.standard.set(object["user_id"] as! Int, forKey: "tmp_id")
                    print(KeychainWrapper.standard.string(forKey: "tmp_token"))
                    print(KeychainWrapper.standard.integer(forKey: "tmp_id"))
                    self.performSegue(withIdentifier: "toResend", sender: nil)
                }
            }
        }
    }
    
    @IBAction func clickForgotPass(_ sender: Any) {
        performSegue(withIdentifier: "toForgot", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toForgot" {
            let forgotView: ForgotPassViewController = (segue.destination as? ForgotPassViewController)!
        } else if segue.identifier == "toResend" {
            let checkView: CheckRegisterVC = (segue.destination as? CheckRegisterVC)!
            checkView.email = emailField.text
        }
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String){
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.emailField:
            self.emailField.becomeFirstResponder()
        case self.passField:
            self.passField.becomeFirstResponder()
        default:
            self.passField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tagBasedTextField(textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if emailField.text != "" && passField.text != "" && isValidEmail(emailField.text!){
            loginButton.isEnabled = true
            loginButton.backgroundColor = #colorLiteral(red: 0.08375196904, green: 0.6392284632, blue: 0.5047482848, alpha: 1)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = #colorLiteral(red: 0.08375196904, green: 0.6392284632, blue: 0.5047482848, alpha: 0.25)
        }
    }
    
    func setTextField(){
        emailField.tag = 1
        passField.tag = 2
        emailField.delegate = self
        passField.delegate = self
    }
    
    private func tagBasedTextField(_ textField: UITextField) {
        let nextTextFieldTag = textField.tag + 1
        if let nextTextField = textField.superview?.viewWithTag(nextTextFieldTag) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailField.endEditing(true)
        passField.endEditing(true)
    }
}
