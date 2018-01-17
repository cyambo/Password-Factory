//
//  AppDelegate.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 10/11/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        UIView.appearance().tintColor = PFConstants.tintColor

        return true
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }


    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        PasswordStorage.get().receivedUpdatedData(notification) { (complete) in
            if complete {
                completionHandler(.newData)
                if let storedVC = ((application.keyWindow?.rootViewController as? UINavigationController)?.viewControllers[0] as? TypeSelectionViewController)?.currentViewController as? StoredPasswordViewController {
                    storedVC.receivedUpdatedData()
                }
                
            } else {
                completionHandler(.failed)
            }
        }
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortCutItem(shortCutItem: shortcutItem))
    }
    func handleShortCutItem(shortCutItem: UIApplicationShortcutItem) -> Bool {
        let d = DefaultsManager.get()
        //get the type of the shortcut item
        if let key = Int(shortCutItem.type) {
            
            //set the defaults key for the type selected from the shortcut
            d.setInteger(key, forKey: "selectedPasswordType")
            
            //make sure everything is good and it is a navigation controller
            if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                //and that the root is the TypeSelectionViewController
                if let typeVC = navController.viewControllers[0] as? TypeSelectionViewController {

                    //if there is more than one controller, (ie prefs is shown)
                    if navController.viewControllers.count > 1 {
                        let navCount = navController.viewControllers.count
                        //pop them all off to the beginning
                        for _ in 1 ..< navCount  {
                            navController.popViewController(animated: false)
                        }
                    }

                    //and select and display it only if the view has been loaded
                    //if it wasn't loaded we are in launch and just setting the default is enough
                    if navController.viewControllers[0].isViewLoaded {
                        guard let selType = typeVC.setSelectedPasswordType() else { return true }
                        typeVC.selectAndDisplay(type: selType, copy: true)
                    }
                }
            }
        }
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Utilities.setHomeScreenActions()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

