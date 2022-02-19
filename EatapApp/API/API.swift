//
//  API.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/03/24.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class API {
    var token = ""
    let base = Configuration.shared.apiUrl
    
    init(token: String = ""){
        self.token = token
    }
    
    func register(params: [String: String], callback: @escaping (JSON)-> ()){
        let url = base + "/register"
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func login(params: [String: String], callback: @escaping (JSON)-> ()){
        let url = base + "/login"
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func logout(params: [String: String], callback: @escaping (JSON)-> ()){
        let url = base + "/logout"
        let token = KeychainWrapper.standard.string(forKey: "token")
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func update(params: [String: String], callback: @escaping (JSON)-> ()){
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let url = base + "/user/\(String(userId!))/update"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func sendAppDeviceToken(params: [String: String], callback: @escaping (JSON)-> ()){
        let token = KeychainWrapper.standard.string(forKey: "token")
        let url = base + "/get_device_token"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func useCoupon(params: [String: String], callback: @escaping (JSON)-> ()){
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let shopId = UserDefaults.standard.integer(forKey: "storeId")
        let url = base + "/coupon/\(String(shopId))/\(String(userId!))"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func createReview(params: [String: String], callback: @escaping (JSON)-> ()){
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let shopId = UserDefaults.standard.integer(forKey: "storeId")
        let url = base + "/review/make/\(String(shopId))/\(String(userId!))"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func contact(params: [String: String], callback: @escaping (JSON)-> ()){
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let url = base + "/contact/\(String(userId!))"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            print(response)
            callback(JSON(response.value as Any))
        }
    }
    
    func verify(params: [String: String], callback: @escaping (JSON)-> ()){
        let token = KeychainWrapper.standard.string(forKey: "tmp_token")
        let userId = KeychainWrapper.standard.integer(forKey: "tmp_id")
        let url = base + "/verify/\(String(userId!))"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            print(response)
            callback(JSON(response.value as Any))
        }
    }
    
    func updateFavoriteState(params: [String: String], callback: @escaping (JSON)-> ()) {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let shopId = UserDefaults.standard.integer(forKey: "storeId")
        let url = base + "/favorite/\(shopId)/\(userId!)"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func sendLotoResult(params: [String: String], callback: @escaping (JSON)-> ()) {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let url = base + "/loto/\(userId!)"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func readArticle(params: [String: String], callback: @escaping (JSON)-> ()) {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let url = base + "/read_article"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }

    
    func changePass(params: [String: String], callback: @escaping (JSON)-> ()) {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let url = base + "/change_pass/\(userId!)"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func changeForgetPass(params: [String: String], callback: @escaping (JSON)-> ()) {
        let url = base + "/change_forget_pass"
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func passForget(params: [String: String], callback: @escaping (JSON)-> ()) {
        let url = base + "/forget_pass"
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func resend(params: [String: String], callback: @escaping (JSON)-> ()){
        let url = base + "/resend_token"
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }
    
    func readAll(params: [String: String], callback: @escaping (JSON)-> ()) {
        let token = KeychainWrapper.standard.string(forKey: "token")
        let userId = KeychainWrapper.standard.integer(forKey: "my_id")
        let url = base + "/read_articles"
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token!),
            .accept("application/json")
        ]
        AF.request(url, method: .post, parameters: params, headers: headers).responseJSON {(response) in
            callback(JSON(response.value as Any))
        }
    }

}
