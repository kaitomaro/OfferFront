//
//  TimeModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct TimeModel: Codable {
    var id:Int?
    var shop_id: Int?
    var start_time: String
    var end_time: String
    var monday: Int?
    var tsuesday: Int?
    var wednesday: Int?
    var thursday: Int?
    var friday: Int?
    var saturday: Int?
    var sunday: Int?
    var time_type: Int?
}
