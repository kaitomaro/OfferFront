//
//  ProfileViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/04/21.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire



class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var dobView: UIView!
    @IBOutlet weak var favPlaceView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var area1Field: UITextField!
    @IBOutlet weak var area2Field: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var nameValidLabel: UILabel!
    
    var genderPickerView = UIPickerView()
    var jobPickerView = UIPickerView()
    var areaPickerView = UIPickerView()
    var dobPicker = UIDatePicker()
    let baseUrl = Configuration.shared.apiUrl
    var jobData = ["" ,"会社員", "公務員", "自営業", "会社役員", "自由業", "専業主婦(夫)", "学生", "パート・アルバイト", "無職"]
    var genderData = ["", "男性", "女性", "その他"]

    var area1Data = ["東京"]
    var area2Data = [
        "", "新宿・代々木", "渋谷・原宿・表参道", "恵比寿・代官山・目黒", "五反田・品川", "六本木・広尾・赤坂", "浜松町・三田・田町", "新橋・有楽町・銀座", "東京・日本橋・茅場町",  "池袋・目白・高田馬場", "四谷・神楽坂・飯田橋", "上野・御徒町・浅草", "水道橋・神田・秋葉原",
        "中野・吉祥寺・三鷹", "その他"
    ]
    var api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        setPlaceHolder()
        submitButton.layer.cornerRadius = 23
        createGenderPickerView(pickerView: genderPickerView, textFiled: genderField, tag: 0)
        createJobPickerView(pickerView: jobPickerView, textFiled: jobField, tag: 1)
        createAreaPickerView(pickerView: areaPickerView, textFiled: area2Field, tag: 2)
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
        initTextField(textField: genderField, placeholder: "性別")
        initTextField(textField: jobField, placeholder: "職種")
        initTextField(textField: dobField, placeholder: "生年月日")
        initTextField(textField: area1Field, placeholder: "東京")
        initTextField(textField: area2Field, placeholder: "選択してください")
    }
    
    func getUserInfo() {
        var token = KeychainWrapper.standard.string(forKey: "token")
        var userId = KeychainWrapper.standard.integer(forKey: "my_id")
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
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    let userModel = try decoder.decode(UserModel.self, from: data)
                    self.nameField.text = userModel.name
                    if userModel.gender != nil {
                        self.genderField.text = userModel.gender!
                    }
                    
                    if userModel.job != nil {
                        self.jobField.text = userModel.job!
                    }
                    
                    if userModel.dob != nil {
                        self.dobField.text = userModel.dob!
                    }
                    
                    if userModel.favarite_area != nil {
                        self.area1Field.text = userModel.favarite_area!
                    } else {
                        self.area1Field.text = "東京"
                    }
                    
                    if userModel.favarite_area2 != nil {
                        self.area2Field.text = userModel.favarite_area2!
                    } else {
                        self.area2Field.text = ""
                    }
                    
                } catch let error {
                        print("error decode json \(error)")
                }
            case .failure(let error):
                print("RESPONSE ERROR：", error)
            }
        }
    }
    
    func createJobPickerView(pickerView: UIPickerView, textFiled: UITextField, tag: Int) {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.tag = tag
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var doneItem = UIBarButtonItem()
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneJobPicker))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        textFiled.inputView = pickerView
        textFiled.inputAccessoryView = toolbar
    }
    
    func createGenderPickerView(pickerView: UIPickerView, textFiled: UITextField, tag: Int) {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.tag = tag
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var doneItem = UIBarButtonItem()
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneGenderPicker))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        textFiled.inputView = pickerView
        textFiled.inputAccessoryView = toolbar
    }
    
    func createAreaPickerView(pickerView: UIPickerView, textFiled: UITextField, tag: Int) {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.tag = tag
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var doneItem = UIBarButtonItem()
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAreaPicker))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        textFiled.inputView = pickerView
        textFiled.inputAccessoryView = toolbar
    }
    
    func createDtPicker() {
        let minDateString = "1900-01-01"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let minDate = dateFormatter.date(from: minDateString)
        let maxDate = Date()
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
    
    @IBAction func tappedSumitButton(_ sender: Any) {
        api.update(params: [
            "name": nameField.text!,
            "gender": genderField.text!,
            "dob": dobField.text!,
            "job": jobField.text!,
            "favarite_area": area1Field.text!,
            "favarite_area2": area2Field.text!
        ]) { (json) in
            if (json["errors"].exists()){
                print(json["errors"])
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc internal func onDidChangeDate(sender: UIDatePicker){
        if nameField.text != "" && isValidUserName(nameField.text!) {
            submitButton.isEnabled = true
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            nameValidLabel.isHidden = true
        }
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = formatter.string(from: sender.date)
        dobField.text = selectedDate
    }
    
    @objc func doneJobPicker() {
        if nameField.text != "" && isValidUserName(nameField.text!) {
            submitButton.isEnabled = true
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            nameValidLabel.isHidden = true
        }
        jobField.endEditing(true)
        jobField.text = "\(jobData[jobPickerView.selectedRow(inComponent: 0)])"
    }
    
    @objc func doneGenderPicker() {
        if nameField.text != "" && isValidUserName(nameField.text!) {
            submitButton.isEnabled = true
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            nameValidLabel.isHidden = true
        }
        genderField.endEditing(true)
        genderField.text = "\(genderData[genderPickerView.selectedRow(inComponent: 0)])"
    }
    
    @objc func doneAreaPicker() {
        if nameField.text != "" && isValidUserName(nameField.text!) {
            submitButton.isEnabled = true
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            nameValidLabel.isHidden = true
        }
        area2Field.endEditing(true)
        area2Field.text = "\(area2Data[areaPickerView.selectedRow(inComponent: 0)])"
    }
    
    @objc func doneDatePicker() {
        if nameField.text != "" && isValidUserName(nameField.text!) {
            submitButton.isEnabled = true
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
            nameValidLabel.isHidden = true
        }
        dobField.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = "プロフィール編集"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
    
    func isValidUserName(_ userName: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-zぁ-んァ-ン一-龥\\s]+$"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: userName)
    }
}

extension ProfileViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String){
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.nameField:
            self.nameField.becomeFirstResponder()
        case self.genderField:
            self.genderField.becomeFirstResponder()
        case self.jobField:
            self.jobField.becomeFirstResponder()
        case self.dobField:
            self.dobField.becomeFirstResponder()
        case self.area2Field:
            self.area2Field.becomeFirstResponder()
        default:
            self.area2Field.resignFirstResponder()
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
        genderField.tag = 1
        jobField.tag = 2
        dobField.tag = 3
        area2Field.tag = 4
        nameField.delegate = self
        genderField.delegate = self
        jobField.delegate = self
        dobField.delegate = self
        area2Field.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if nameField.text != "" && isValidUserName(nameField.text!) {
            submitButton.isEnabled = true
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1)
        } else {
            if isValidUserName(nameField.text!) {
                nameValidLabel.isHidden = true
            } else {
                nameValidLabel.text = "英数・日本語のみで入力してください。"
                nameValidLabel.isHidden = false
            }
            
            if nameField.text == "" {
                nameValidLabel.text = "ユーザー名は必須です。"
                nameValidLabel.isHidden = false
            }
            submitButton.isEnabled = false
            submitButton.backgroundColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 0.5)
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

extension ProfileViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            genderField.text = genderData[row]
        } else if pickerView.tag == 1 {
            jobField.text = jobData[row]
        } else if pickerView.tag == 2 {
            area2Field.text = area2Data[row]
        }
    }
}

extension ProfileViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return genderData.count
        } else if pickerView.tag == 1 {
            return jobData.count
        } else if pickerView.tag == 2 {
            return area2Data.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return genderData[row]
        }
        if pickerView.tag == 1 {
            return jobData[row]
        }
        if pickerView.tag == 2 {
            return area2Data[row]
        }
        return ""
    }
}
