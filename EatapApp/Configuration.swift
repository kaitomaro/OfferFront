//
//  Configuration.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct Configuration {
    static let shared = Configuration()

    private let config: [AnyHashable: Any] = {
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
        let plist = NSDictionary(contentsOfFile: path) as! [AnyHashable: Any]
        return plist["AppConfig"] as! [AnyHashable: Any]
    }()

    let apiUrl: String
    let couponUrl: String
    let s3Url: String
    
    private init() {
        apiUrl = config["ApiUrl"] as! String
        couponUrl = config["CouponUrl"] as! String
        s3Url = config["S3Url"] as! String
    }
}
