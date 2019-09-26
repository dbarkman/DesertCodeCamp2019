//
//  AppDelegate.swift
//  Desert Code Camp
//
//  Created by David Barkman on 9/8/19.
//  Copyright © 2019 Dbarkman LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UserDefaults.standard.set("dbarkman", forKey: "login")
        
        DispatchQueue.main.async {
            APIServices.getAllData()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let containerViewController = ContainerViewController()
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()

        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")

        return true
    }
}

