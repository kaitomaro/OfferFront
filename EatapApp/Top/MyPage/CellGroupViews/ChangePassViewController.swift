//
//  ChangePassViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire

class ChangePassViewController: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var currentPassField: UITextField!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    @IBOutlet weak var confirmAlertLabel: UILabel!
    @IBOutlet weak var newPassLabel: UILabel!
    @IBOutlet weak var checkPassLabel: UILabel!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var currentPassLabel: UILabel!
    @IBOutlet weak var newPassAlertLabel: UILabel!
    @IBOutlet weak var currentPassAlertLabel: UILabel!
    
    var api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceHolder()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        submitButton.layer.cornerRadius = 23
        setTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.title = "パスワード変更"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }

    
    func initTextField(textField:UITextField, placeholder: String){
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor :#colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)])
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
    }
    
    func setPlaceHolder() {
        initTextField(textField: currentPassField, placeholder: "現在のパスワード")
        initTextField(textField: newPassField, placeholder: "新しいパスワード")
        initTextField(textField: confirmPassField, placeholder: "確認")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toForgotVC" {
            let forgotView: ForgotPassViewController = (segue.destination as? ForgotPassViewController)!
        }
    }
    
    @IBAction func Submittapped(_ sender: Any) {
        api.changePass(params: [
            "pass": currentPassField.text!,
            "new_pass": newPassField.text!
            
        ])
        { (json) in
            if (json["errors"].exists()){
                self.currentPassAlertLabel.isHidden = false
                self.currentPassAlertLabel.text = json["errors"].stringValue
                return
            }
            else{
                let alert = UIAlertController(title: "Eatap", message: "パスワードが変更されました", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
                    print("OK")
                    self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func tappedForgot(_ sender: Any) {
        performSegue(withIdentifier: "toForgotVC", sender: nil)
    }
}

extension ChangePassViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String){
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.currentPassField:
            self.currentPassField.becomeFirstResponder()
        case self.newPassField:
            self.newPassField.becomeFirstResponder()
        case self.confirmPassField:
            self.confirmPassField.becomeFirstResponder()
        default:
            self.confirmPassField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tagBasedTextField(textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if currentPassField.text != "" && newPassField.text != "" && confirmPassField.text != "" && newPassField.text == confirmPassField.text && currentPassField.text != newPassField.text {
            submitButton.isEnabled = true
            newPassAlertLabel.isHidden = true
            currentPassAlertLabel.isHidden = true
            confirmAlertLabel.isHidden = true
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 0.5)
        }
        if currentPassField.text == newPassField.text {
            newPassAlertLabel.isHidden = false
            submitButton.isEnabled = false
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 0.5)
        }
        if newPassField.text != confirmPassField.text {
            confirmAlertLabel.isHidden = false
            submitButton.isEnabled = false
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 0.5)
        }
    }
    
    func setTextField(){
        currentPassField.tag = 1
        newPassField.tag = 2
        confirmPassField.tag = 3
        currentPassField.delegate = self
        newPassField.delegate = self
        confirmPassField.delegate = self
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
        currentPassField.endEditing(true)
        newPassField.endEditing(true)
        confirmPassField.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultText: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if resultText.count <= 15 {
            return true
        }
        return false
    }
}
