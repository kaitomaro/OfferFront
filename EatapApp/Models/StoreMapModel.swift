//
//  StoreMapModel.swift
//  
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
    var opened: Int?
    var category_1: Int?
    var category_2: Int?
    var latitude: Double?
    var longitude: Double?
    var favorite_id: Int?
    var priority: Int?
    var lunch_estimated_bottom_price: Int?
    var lunch_estimated_high_price: Int?
    var dinner_estimated_bottom_price: Int?
    var dinner_estimated_high_price: Int?
}
