//
//  DetailDatum.swift
//  
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct DetailDatum: Codable {
    var store: StoreModel
    var time1: [TimeModel]
    var time2: [TimeModel]
}
