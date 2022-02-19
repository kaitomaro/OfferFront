//
//  HistoryModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct HistoryModel: Codable {
    var user_id: Int?
    var shop_id: Int?
    var created_at: String?
    var name: String?
    var top_image: String?
    var people: Int?
    var discount: Int?
    var discount_type: Int?
    var service_type: Int?
    var menu_name: String?
}
