//
//  StoreModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct StoreModel: Codable {
    var id: Int
    var name: String
    var zip_code: String
    var address: String
    var phone: String?
    var top_image: String?
    var sentence: String?
    var sns: String?
    var hp: String?
    var payment_options: String?
    var number_of_seats: String?
    var opened: Int?
    var is_vip: Int?
    var favorite_id: Int?
    var category_1: Int?
    var category_2: Int?
    var lunch_estimated_bottom_price: Int?
    var lunch_estimated_high_price: Int?
    var dinner_estimated_bottom_price: Int?
    var dinner_estimated_high_price: Int?
    var holiday: String?
    var twitter: String?
    var facebook: String?
    var instagram: String?
}

