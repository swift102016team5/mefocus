//
//  AppDelegate.swift
//  MeFocus
//
//  Created by Enta'ard on 11/15/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

let returnNotification = "returnToApp"
let enterForegroundNotification = "appWillEnterForeground"
let saveCurrentTimeNotification = "saveCurrentTime"
let resumeTimerNotification = "resumeTimer"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceLocked = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(
            options: [.alert, .sound],
            completionHandler: { (granted, error) in
            }
        )

        registerforDeviceLockNotification()
        
        // Finish old ongoing session
        SessionsManager.unfinished?.finish()
        
        // Check if any unfinished session is going
//        let session = SessionsManager.unfinished
//        if session != nil {
//            App.shared.redirect(
//                delegate: self,
//                storyboard: "Session",
//                controller: "SessionOngoingViewController",
//                modifier:{(controller:UIViewController) in
//                    let ongoing = controller as! SessionOngoingViewController
//                    ongoing.session = session
//                }
//            )
//            return true
//        }
        
        // If user havent seen onboard screen , navigate to it
        if !App.shared.isViewedOnboard() {
            App.shared.redirect(
                delegate: self,
                storyboard: "Onboard",
                controller: "OnboardIntroViewController",
                modifier:nil
            )
            return true
        }
        
        // Navigate user direct to create new session
        App.shared.redirect(
            delegate: self,
            storyboard: "Session",
            controller: "SessionStartViewController",
            modifier:nil
        )
        return true
        
        
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
//        let controller: UserLoginViewController = storyboard.instantiateViewController(withIdentifier: "UserLoginViewController") as! UserLoginViewController
//        
//        self.window?.rootViewController = controller
//        
//        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        guard deviceLocked else {
            NotificationCenter.default.post(name: NSNotification.Name(returnNotification), object: self)
            return
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(saveCurrentTimeNotification), object: self)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        guard deviceLocked else {
            NotificationCenter.default.post(name: NSNotification.Name(enterForegroundNotification), object: self)
            return
        }
        
        deviceLocked = false
        NotificationCenter.default.post(name: NSNotification.Name(resumeTimerNotification), object: self)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        // Stop session when app is terminated
        SessionsManager.unfinished?.finish()
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MeFocus")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func registerforDeviceLockNotification() {
        // Void pointer to `self`:
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), observer, { (center, observer, name, object, userInfo) -> Void in
            // the "com.apple.springboard.lockcomplete" notification will always come after the "com.apple.springboard.lockstate" notification
            let lockState = name?.rawValue as! String
            if lockState == "com.apple.springboard.lockcomplete", let observer = observer {
                let this = Unmanaged<AppDelegate>.fromOpaque(observer).takeUnretainedValue()
                this.deviceLocked = true
                NSLog("DEVICE LOCKED")
            }
            else {
                NSLog("LOCK STATUS CHANGED")
            }
        }, "com.apple.springboard.lockcomplete" as CFString!, nil, CFNotificationSuspensionBehavior.deliverImmediately)
    }
    
}

