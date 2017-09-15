//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Yeontae Kim on 7/19/17.
//  Copyright © 2017 YTK. All rights reserved.
//
//  AppDelegate code below created based on the solution from Big Nerd Ranch's iOS Programming(6th ed).
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let store = PhotoStore()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        store.persistentContainer.saveContextIfNeeded()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        store.persistentContainer.saveContextIfNeeded()
    }


}

