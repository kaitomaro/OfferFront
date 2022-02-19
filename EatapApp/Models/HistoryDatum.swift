//
//  HistoryDatum.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct HistoryDatum: Codable {
    var history: [HistoryModel]?
    var today: [HistoryModel]?
}
