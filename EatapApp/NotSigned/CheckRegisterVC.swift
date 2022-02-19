//
//  CheckRegisterVC.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/06/06.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class CheckRegisterVC: UIViewController {

    @IBOutlet weak var sentenceLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    
    var email:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func resendTapped(_ sender: Any) {
        resendButton.isEnabled = false
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let api = API()
        api.resend(params: [
            "email": email!,
            "device_name": deviceId
        ]) { (json) in
            if (json["errors"].exists()){
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
                self.resendButton.isHidden = true
            }
        }
    }
}
