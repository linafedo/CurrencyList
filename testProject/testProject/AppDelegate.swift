//
//  AppDelegate.swift
//  testProject
//
//  Created by Galina Fedorova on 05.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window: UIWindow = {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .systemBackground
            window.rootViewController = RatesViewController()
            window.makeKeyAndVisible()
            return window
        }()
        
        self.window = window

        return true
    }

}
