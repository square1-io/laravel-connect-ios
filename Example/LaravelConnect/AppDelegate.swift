//
//  AppDelegate.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 11/19/2017.
//  Copyright (c) 2017 Roberto Prato. All rights reserved.
//

import UIKit
import LaravelConnect
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        LaravelConnect.configure(settings: SampleAppConnectSettings(), onCompletion: {
         
            var filter = Filter().contains(param: "medias.event_id", value: "1")
                .contains(param: "medias.event_id", value: "2")
                .contains(param: "medias.event_id", value: "3")
                .or()
                .equal(param: "id", value: "33")
            
            let list = City.list(filter: filter)
            
            
        });
    
      
        
//        //**
//        "filter[0][medias.event_id][equal][0]": eventId,
//        "filter[0][medias.event_id][equal][1]": 5,
//        "filter[0][id][equal][1]": 52323,
//        "filter[1][medias.event_id][equal][0]": 666,
//        "filter[1][medias.event_id][equal][1]": 666,
//        "filter[1][id][equal][1]": 52323
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

