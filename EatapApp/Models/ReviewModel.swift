//
//  ReviewModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct ReviewModel: Codable {
    var sentence: String
    var rate: Double?
    var shop_id: Int?
    var user_id: Int?
    var created_at:String?
    var name: String
}
