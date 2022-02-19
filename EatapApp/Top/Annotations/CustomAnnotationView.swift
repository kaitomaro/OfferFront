//
//  CustomAnnotationView.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/07/24.
//

import UIKit
import MapKit


class CustomAnnotationView: MKMarkerAnnotationView {
    static let identifier = "CustomAnnotationView"
    override func prepareForDisplay() {
        super.prepareForDisplay()
    }

    func setup() {
        clusteringIdentifier = "clusteringIdentifier"
    }
}
