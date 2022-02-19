//
//  RegisterViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/03/24.
//

import UIKit
import SwiftyJSON
import SwiftKeychainWrapper

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var mailView: UIView!
    @IBOutlet weak var passView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var dobView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var passCheckField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var emailValidLabel: UILabel!
    @IBOutlet weak var nameValidLabel: UILabel!
    @IBOutlet weak var passValidLabel: UILabel!
    
    @IBOutlet weak var registerLoadView: UIView!
    var activityIndicatorView = UIActivityIndicatorView()
    let api = API()
    
    var genderPickerView = UIPickerView()
    var jobPickerView = UIPickerView()
    var dobPicker = UIDatePicker()
    var genderData = ["", "男性", "女性", "その他"]
    var jobData = ["", "会社員", "公務員", "自営業", "会社役員", "自由業", "専業主婦(夫)", "学生", "パート・アルバイト", "無職"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPlaceHolder()
        registerLoadView.isHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        registerButton.layer.cornerRadius = 23
        registerButton.isEnabled = false
        createPickerView(pickerView: genderPickerView, textFiled: genderField, tag: 0)
        createPickerView(pickerView: jobPickerView, textFiled: jobField, tag: 1)
        createDtPicker()
        setTextField()
    }
    
    func initTextField(textField:UITextField, placeholder: String){
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor :#colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)])
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
    }
    
    func setPlaceHolder() {
        initTextField(textField: nameField, placeholder: "英数字または日本語(15字以内)")
        initTextField(textField: emailField, placeholder: "メールアドレス")
        initTextField(textField: passField, placeholder: "半角英数(15字以内)")
        initTextField(textField: passCheckField, placeholder: "確認")
        initTextField(textField: dobField, placeholder: "生年月日")
        initTextField(textField: genderField, placeholder: "性別")
        initTextField(textField: jobField, placeholder: "選択してください")
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
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^([A-Z0-9a-z._+-])+@([A-Za-z0-9.-])+\\.([A-Za-z]{2,})$"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidUserName(_ userName: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-zぁ-んァ-ン一-龥\\s]+$"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: userName)
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        registerButton.isEnabled = false
        registerLoadView.isHidden = false
        activityIndicatorView.style = .large
        activityIndicatorView.center = view.center
        activityIndicatorView.color = .black
        registerLoadView.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        
        guard let name = nameField.text, let email = emailField.text, let pass = passField.text, let dob = dobField.text, let gender = genderField.text, let job = jobField.text  else {
            return
        }
        
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        if passField.text != passCheckField.text {
            passValidLabel.isHidden = false
            return
        }
        
        api.register(params: [
            "name": name,
            "email": email,
            "password": pass,
            "dob": dob,
            "gender": gender,
            "job": job,
            "device_name": deviceId
        ]) { (json) in
            if (json["errors"].exists()){
                for i in json["errors"] {
                    do {
                        print(i.0)
                        if i.0 == "email" {
                            self.emailValidLabel.isHidden = false
                            self.emailValidLabel.text = "このメールアドレスは既に使用されています。"
                            
                        }
                    } catch {
                        print(error)
                    }
                }
                self.activityIndicatorView.stopAnimating()
                self.registerLoadView.isHidden = true
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
                self.performSegue(withIdentifier: "toCheckEmail", sender: nil)
            }
            self.activityIndicatorView.stopAnimating()
            self.registerLoadView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCheckEmail") {
            let checkVC: CheckRegisterVC = (segue.destination as? CheckRegisterVC)!
            checkVC.email = emailField.text
        }
    }
    
    
    func createPickerView(pickerView: UIPickerView, textFiled: UITextField, tag: Int) {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.tag = tag
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var doneItem = UIBarButtonItem()
        
        if pickerView == genderPickerView {
            doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneGenderPicker))
        } else if pickerView == jobPickerView {
            doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneJobPicker))
        }
        toolbar.setItems([spacelItem, doneItem], animated: true)
        textFiled.inputView = pickerView
        textFiled.inputAccessoryView = toolbar
    }
    
    func createDtPicker() {
        let minDateString = "1900-01-01"
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var minDate = dateFormatter.date(from: minDateString)
        var maxDate = Date()
        dobPicker.datePickerMode = .date
        dobPicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dobPicker.preferredDatePickerStyle = .wheels
        dobField.inputView = dobPicker
        dobPicker.minimumDate = minDate
        dobPicker.maximumDate = maxDate
        dobPicker.addTarget(self, action:  #selector(onDidChangeDate(sender:)), for: .valueChanged)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var doneItem = UIBarButtonItem()
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDatePicker))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        dobField.inputAccessoryView = toolbar
    }
    
    @objc internal func onDidChangeDate(sender: UIDatePicker) {
        if nameField.text != "" && emailField.text != "" && passField.text != "" && passCheckField.text != "" && isValidEmail(emailField.text!) && passField.text == passCheckField.text && isValidUserName(nameField.text!) {
            registerButton.isEnabled = true
            registerButton.backgroundColor = #colorLiteral(red: 0.08375196904, green: 0.6392284632, blue: 0.5047482848, alpha: 1)
            nameValidLabel.isHidden = true
            emailValidLabel.isHidden = true
            passValidLabel.isHidden = true
        }
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = formatter.string(from: sender.date)
        dobField.text = selectedDate
     }
    
    @objc func doneGenderPicker() {
        if nameField.text != "" && emailField.text != "" && passField.text != "" && passCheckField.text != "" && isValidEmail(emailField.text!) && passField.text == passCheckField.text && isValidUserName(nameField.text!) {
            registerButton.isEnabled = true
            registerButton.backgroundColor = #colorLiteral(red: 0.08375196904, green: 0.6392284632, blue: 0.5047482848, alpha: 1)
            nameValidLabel.isHidden = true
            emailValidLabel.isHidden = true
            passValidLabel.isHidden = true
        }
        genderField.endEditing(true)
        genderField.text = "\(genderData[genderPickerView.selectedRow(inComponent: 0)])"
    }
    
    @objc func doneDatePicker() {
        if nameField.text != "" && emailField.text != "" && passField.text != "" && passCheckField.text != "" && isValidEmail(emailField.text!) && passField.text == passCheckField.text && isValidUserName(nameField.text!) {
            registerButton.isEnabled = true
            registerButton.backgroundColor = #colorLiteral(red: 0.08375196904, green: 0.6392284632, blue: 0.5047482848, alpha: 1)
            nameValidLabel.isHidden = true
            emailValidLabel.isHidden = true
            passValidLabel.isHidden = true
        }
        dobField.endEditing(true)
    }

    @objc func doneJobPicker() {
        jobField.endEditing(true)
        if nameField.text != "" && emailField.text != "" && passField.text != "" && passCheckField.text != "" && isValidEmail(emailField.text!) && passField.text == passCheckField.text && isValidUserName(nameField.text!) {
            registerButton.isEnabled = true
            registerButton.backgroundColor = #colorLiteral(red: 0.08375196904, green: 0.6392284632, blue: 0.5047482848, alpha: 1)
            nameValidLabel.isHidden = true
            emailValidLabel.isHidden = true
            passValidLabel.isHidden = true
        }
        jobField.text = "\(jobData[jobPickerView.selectedRow(inComponent: 0)])"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameField.endEditing(true)
        emailField.endEditing(true)
        passField.endEditing(true)
        passCheckField.endEditing(true)
        dobField.endEditing(true)
        genderField.endEditing(true)
        jobField.endEditing(true)
    }
}

extension RegisterViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String){
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.nameField:
            self.nameField.becomeFirstResponder()
        case self.emailField:
            self.emailField.becomeFirstResponder()
        case self.passField:
            self.passField.becomeFirstResponder()
        case self.passCheckField:
            self.passCheckField.becomeFirstResponder()
        case self.dobField:
            self.dobField.becomeFirstResponder()
        case self.genderField:
            self.genderField.becomeFirstResponder()
        case self.jobField:
            self.jobField.becomeFirstResponder()
        default:
            self.jobField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tagBasedTextField(textField)
        return true
    }
    
    private func tagBasedTextField(_ textField: UITextField) {
        let nextTextFieldTag = textField.tag + 1
        if let nextTextField = textField.superview?.viewWithTag(nextTextFieldTag) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
    func setTextField(){
        nameField.tag = 0
        emailField.tag = 1
        passField.tag = 2
        passCheckField.tag = 3
        dobField.tag = 4
        genderField.tag = 5
        jobField.tag = 6
        nameField.delegate = self
        emailField.delegate = self
        passField.delegate = self
        passCheckField.delegate = self
        dobField.delegate = self
        genderField.delegate = self
        jobField.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if nameField.text != "" && emailField.text != "" && passField.text != "" && passCheckField.text != "" && isValidEmail(emailField.text!) && passField.text == passCheckField.text && isValidUserName(nameField.text!) {
            registerButton.isEnabled = true
            registerButton.backgroundColor = #colorLiteral(red: 0.08375196904, green: 0.6392284632, blue: 0.5047482848, alpha: 1)
            nameValidLabel.isHidden = true
            emailValidLabel.isHidden = true
            passValidLabel.isHidden = true
        } else {
            if isValidEmail(emailField.text!) {
                emailValidLabel.isHidden = true
            } else {
                emailValidLabel.text = "正しいメールアドレスを入力してください。"
                emailValidLabel.isHidden = false
            }
            
            if isValidUserName(nameField.text!) {
                nameValidLabel.isHidden = true
            } else {
                nameValidLabel.text = "英数・日本語のみで入力してください。"
                nameValidLabel.isHidden = false
            }
            
            if passField.text == passCheckField.text {
                passValidLabel.isHidden = true
            } else {
                passValidLabel.isHidden = false
            }
            registerButton.isEnabled = false
            registerButton.backgroundColor = #colorLiteral(red: 0.08375196904, green: 0.6392284632, blue: 0.5047482848, alpha: 0.25)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            let resultText: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if resultText.count <= 15 {
                return true
            }
            return false
        } else {
          return true
        }
    }
}

extension RegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            genderField.text = genderData[row]
        } else if pickerView.tag == 1 {
            jobField.text = jobData[row]
        }
    }
}

extension RegisterViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return genderData.count
        } else if pickerView.tag == 1 {
            return jobData.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return genderData[row]
        } else if pickerView.tag == 1 {
            return jobData[row]
        }
        return ""
    }
}
