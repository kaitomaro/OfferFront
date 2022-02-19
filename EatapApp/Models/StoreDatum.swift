//
//  StoreDatum.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/12.
//

import Foundation

struct StoreDataum: Codable {
    var store: StoreModel
    var discount: [Int]
    var imgs: [ImgModel]
    var coupons: [[CouponModel]]
}
