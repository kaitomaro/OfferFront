//
//  ChangeForgotPassVC.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/06/17.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class ChangeForgotPassVC: UIViewController {
    
    @IBOutlet weak var newPassLabel: UILabel!
    @IBOutlet weak var newPassAlertLabel: UILabel!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var checkPassLabel: UILabel!
    @IBOutlet weak var checkPassAlertLabel: UILabel!
    @IBOutlet weak var checkPassField: UITextField!
    @IBOutlet weak var summitButton: UIButton!
    var api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceHolder()
        summitButton.layer.cornerRadius = 23
        newPassField.becomeFirstResponder()
        setTextField()
    }

    func initTextField(textField:UITextField, placeholder: String){
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor :#colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 0.7008064159)])
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
    }
        
    func setPlaceHolder() {
        initTextField(textField: newPassField, placeholder: "新しいパスワード")
        initTextField(textField: checkPassField, placeholder: "確認")
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        summitButton.isEnabled = false
        summitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 0.5)
        api.changeForgetPass(params: [
            "email": KeychainWrapper.standard.string(forKey: "tmp_email")!,
            "pass": newPassField.text!
        ]) { (json) in
            if (json["errors"].exists()){
                self.newPassAlertLabel.isHidden = false
                self.newPassAlertLabel.text = json["errors"].stringValue
                return
            }

            let alert = UIAlertController(title: "Eatap", message: "パスワードが変更されました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
                KeychainWrapper.standard.removeObject(forKey: "tmp_email")
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ChangeForgotPassVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String){
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.newPassField:
            self.newPassField.becomeFirstResponder()
        case self.checkPassField:
            self.checkPassField.becomeFirstResponder()
        default:
            self.checkPassField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tagBasedTextField(textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if newPassField.text != "" && checkPassField.text != "" && newPassField.text == checkPassField.text {
            summitButton.isEnabled = true
            newPassAlertLabel.isHidden = true
            checkPassAlertLabel.isHidden = true
            summitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
        } else {
            summitButton.isEnabled = false
            summitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 0.5)
        }

        if newPassField.text != checkPassField.text {
            checkPassAlertLabel.isHidden = false
            summitButton.isEnabled = false
            summitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 0.5)
        }
    }
    
    func setTextField(){
        newPassField.tag = 1
        checkPassField.tag = 2
        newPassField.delegate = self
        checkPassField.delegate = self
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
        newPassField.endEditing(true)
        checkPassField.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultText: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if resultText.count <= 15 {
            return true
        }
        return false
    }
}
