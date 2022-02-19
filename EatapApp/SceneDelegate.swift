//
//  SceneDelegate.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2020/11/06.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        UIApplication.shared.applicationIconBadgeNumber = 0
        if (KeychainWrapper.standard.string(forKey: "token") != nil &&  KeychainWrapper.standard.integer(forKey: "my_id") != nil ) {
            let nav = UINavigationController()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "Tab") as! TabBarController
            nav.viewControllers = [vc]
            window?.rootViewController = nav
            window?.makeKeyAndVisible()
        } else {
            let nav = UINavigationController()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "Top")
            nav.viewControllers = [vc]
            window?.rootViewController = nav
            window?.makeKeyAndVisible()
        }
        guard let userActivity
            = connectionOptions.userActivities
                .first(where: { $0.webpageURL != nil }) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print(userActivity.webpageURL!)
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return
        }

        guard let path = components.path,
        let params = components.queryItems else {
            return
        }
        if path == "/api/verify" {
            if let id = params.first(where: { $0.name == "id" } )?.value,
                let token = params.first(where: { $0.name == "token" })?.value {
                if (KeychainWrapper.standard.string(forKey: "tmp_token") != nil && KeychainWrapper.standard.integer(forKey: "tmp_id") != nil) {
                    if KeychainWrapper.standard.string(forKey: "tmp_token")! ==  token && KeychainWrapper.standard.integer(forKey: "tmp_id") ==  Int(id) {
                        
                        let api = API()
                        let deviceId = UIDevice.current.identifierForVendor!.uuidString
                        api.verify(params: ["device_name": deviceId]) { (json) in
                            if (json["errors"].exists()){
                                print("we have some errors -- cannot verify")
                                return
                            }
                            
                            var object:[String:Any] = ["user_id": 0, "token": ""]

                            do {
                                object = json.object as! [String : Any]
                            } catch {
                                print(error)
                            }
                            
                            if object["token"] != nil && object["user_id"] != nil {
                                KeychainWrapper.standard.set(object["token"] as! String, forKey: "token")
                                KeychainWrapper.standard.set(object["user_id"] as! Int, forKey: "my_id")
                                if KeychainWrapper.standard.string(forKey: "token") != nil && KeychainWrapper.standard.integer(forKey: "my_id") != nil {
                                    if (KeychainWrapper.standard.string(forKey: "tmp_token") != nil) {
                                        KeychainWrapper.standard.removeObject(forKey: "tmp_token")
                                    }
                                    
                                    if (KeychainWrapper.standard.string(forKey: "tmp_id") != nil) {
                                        KeychainWrapper.standard.removeObject(forKey: "tmp_id")
                                    }
                                    
                                    let nav = UINavigationController()
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(identifier: "Tab") as! TabBarController
                                    nav.viewControllers = [vc]
                                    self.window?.rootViewController = nav
                                    self.window?.makeKeyAndVisible()
                                }
                            }
                        }
                    }
                }
            } else {
                print("")
            }
        }
    }

}

