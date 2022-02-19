//
//  UserModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct UserModel: Codable {
    var name: String
    var gender: String?
    var job: String?
    var dob: String?
    var favarite_area: String?
    var favarite_area2: String?
}
