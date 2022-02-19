//
//  CustomClusterAnnotationView.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/24.
//

import UIKit
import MapKit

/// クラスター化されたピンのAnnotationView
class CustomClusterAnnotationView: MKMarkerAnnotationView {
    static let identifier = "CustomClusterAnnotationView"

    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
//            image = UIImage.clusterImage(count: clusterAnnotation.memberAnnotations.count)
        }
    }
}
