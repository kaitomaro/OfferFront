//
//  CouponModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct CouponModel: Codable {
    var id:Int?
    var coupon_id: Int?
    var time_id:Int?
    var service_type:Int?
    var image_path: String?
    var priority: Int?
    var price:Int?
    var discount:Int?
    var name: String?
    var shop_id: Int?
    var first_time_discount: Int?
    var telephone_reservation: Int?
    var discount_type: Int?
    var time_type:Int?
    var bill_type: Int?
}
