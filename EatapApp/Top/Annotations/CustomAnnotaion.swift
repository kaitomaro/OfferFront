//
//  CustomAnnotaion.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2020/12/25.
//

import UIKit
import MapKit

class CustomAnnotaion: MKPointAnnotation {
    var imageName: String?
    var storeId: Int?
    var discount: Int?
    var category1: String?
    var category2: String?
    var cooridate: CLLocationCoordinate2D?
    var clusteringIdentifier: String?
    var cafeOrRest: Int?
    var priority: Int?
    var lunchPrice: String?
    var dinnerPrice: String?
}
