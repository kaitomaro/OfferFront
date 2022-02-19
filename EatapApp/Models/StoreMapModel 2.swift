//
//  StoreMapModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct StoreMapModel: Codable {
    var first_time_discount: Int?
    var address:String
    var top_image: String?
    var zip_code: String
    var display: Int?
    var coupon_id: Int?
    var id: Int
    var discount_type: Int?
    var time_id: Int?
    var discount: Int?
    var name: String
    var closed: Int?
    var category_1: Int?
    var category_2: Int?
    var favorite_id: Int?
    var priority: Int?
}
