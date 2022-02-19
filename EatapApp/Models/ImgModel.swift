//
//  ImgModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct ImgModel: Codable {
    var id: Int
    var image_name: String
    var shop_id: Int?
    var sort_num: Int?
}
