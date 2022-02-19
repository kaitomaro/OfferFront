//
//  SceneExtention.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/06.
//

import Foundation
import UIKit


extension SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print(userActivity.webpageURL!)
        
    }

}

