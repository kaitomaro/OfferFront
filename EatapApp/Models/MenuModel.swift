//
//  MenuModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct MenuModel: Codable {
    var id: Int
    var name: String
    var shop_id: Int?
    var menu_type: Int?
    var detail:String?
    var price: Int?
}
