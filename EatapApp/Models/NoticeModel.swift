//
//  NoticeModel.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation
struct NoticeModel: Codable {
    var id: Int
    var sender_id: Int
    var title: String
    var body: String?
    var created_at: String
    var marks_id: Int?
}
