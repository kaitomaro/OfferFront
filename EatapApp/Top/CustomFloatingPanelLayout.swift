//
//  CustomFloatingPanelLayout.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/22.
//

import Foundation
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: -40, edge: .bottom, referenceGuide: .safeArea),
        ]
    }

    var supportedPositions: Set<FloatingPanelState> {
        return [.full,.half,.tip]
    }
}
