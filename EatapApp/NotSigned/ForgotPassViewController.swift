
import UIKit
import Alamofire
import SwiftKeychainWrapper


class ForgotPassViewController: UIViewController {
    
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var mailAlertLabel: UILabel!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var sentMessageLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var codeAlertLabel: UILabel!
    @IBOutlet weak var toPassButton: UIButton!
    var api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceHolder()
        mailField.becomeFirstResponder()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        mailField.delegate = self
        codeTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.navigationItem.title = "パスワードを忘れた"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
    
    
    func initTextField(textField:UITextField, placeholder: String){
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor :#colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 0.7008064159)])
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
    }
    
    func setPlaceHolder() {
        initTextField(textField: mailField, placeholder: "メールアドレス")
        initTextField(textField: codeTextField, placeholder: "コード")

    }
    
    @IBAction func sendCodeTapped(_ sender: Any) {
        api.passForget(params: [
            "email": mailField.text!
        ]) { [self] (json) in
            if (json["errors"].exists()){
                return
            }
            KeychainWrapper.standard.set(json.intValue, forKey: "tmp_code")
            KeychainWrapper.standard.set(self.mailField.text!, forKey: "tmp_email")
            if KeychainWrapper.standard.integer(forKey: "tmp_code") != nil && (KeychainWrapper.standard.string(forKey: "tmp_email") != nil) {
                self.sentMessageLabel.isHidden = false
                self.codeLabel.isHidden = false
                self.codeTextField.isHidden = false
                self.toPassButton.isHidden = false
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^([A-Z0-9a-z._+-])+@([A-Za-z0-9.-])+\\.([A-Za-z]{2,})$"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func toPassTapped(_ sender: Any) {
        if KeychainWrapper.standard.integer(forKey: "tmp_code")! == Int(codeTextField.text!) {
            sentMessageLabel.isHidden = true
            codeLabel.isHidden = true
            codeTextField.isHidden = true
            codeTextField.text = ""
            toPassButton.isHidden = true
            sendCodeButton.isEnabled = false
            codeAlertLabel.isHidden = true
            sendCodeButton.setTitleColor(.lightGray, for: .application)
            KeychainWrapper.standard.removeObject(forKey: "tmp_code")
            performSegue(withIdentifier: "showChangePass", sender: nil)
        } else {
            sendCodeButton.isEnabled = false
            codeAlertLabel.isHidden = false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChangePass" {
            let vc: ChangeForgotPassVC = (segue.destination as? ChangeForgotPassVC)!
        }
    }
}

extension ForgotPassViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String){
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if mailField.text != "" && isValidEmail(mailField.text!) {
            sendCodeButton.isEnabled = true
            sendCodeButton.setTitleColor(.link, for: .application)
        } else {
            sendCodeButton.isEnabled = false
            sendCodeButton.setTitleColor(.lightGray , for: .application)
        }
        
        if codeTextField.text != "" && codeTextField.text == String(KeychainWrapper.standard.integer(forKey: "tmp_code")!) {
            toPassButton.isEnabled = true
            toPassButton.setTitleColor(.link, for: .application)
        } else {
            toPassButton.isEnabled = false
            toPassButton.setTitleColor(.lightGray , for: .application)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mailField.text != "" && isValidEmail(mailField.text!) {
            sendCodeButton.isEnabled = true
            sendCodeButton.setTitleColor(.link, for: .application)
        } else {
            sendCodeButton.isEnabled = false
            sendCodeButton.setTitleColor(.lightGray , for: .application)
        }
        mailField.endEditing(true)
        codeTextField.endEditing(true)
    }
}
