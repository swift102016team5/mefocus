//
//  Application.swift
//  MeFocus
//
//  Created by Hao on 11/19/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration
import ChameleonFramework
import SwiftWebSocket
import UserNotifications
/**
 ** Notification struct
 **/

struct WebsocketMessage {

    var title:String
    var body:String
    
    init(message:String){
        
        let messages = message.components(separatedBy: "|")
        
        title = messages[0]
        body = messages[1]
    }
    
}

/**
 ** Theme struct
 **/

struct Theme {
    
    var backgroundLighColor:UIColor
    var backgroundColor:UIColor
    var backgroundDarkColor:UIColor
    var backgroundLighAccentColor:UIColor
    var backgroundDarkAccentColor:UIColor
    
    var textColor:UIColor
    var textDarkColor:UIColor
    
}

/**
 ** Core application with configurations and states
 **/
class App: NSObject {
    
    static private var _shared:App?
    
    static var shared:App{
        
        get {
            if self._shared == nil {
                self._shared = App()
            }
            return self._shared!
        }
        
    }
    
    var theme:Theme
    var ws:WebSocket
    
    override init(){
        // Theming
        theme = Theme(
            backgroundLighColor: .flatGreen,
            backgroundColor: .flatGreen,
            backgroundDarkColor:.flatGreenDark,
            backgroundLighAccentColor:.flatMint,
            backgroundDarkAccentColor:.flatMintDark,
            textColor:.flatWhite,
            textDarkColor:.flatBlack
        )
        ws = WebSocket("wss://mefocusgo.herokuapp.com/ws")
        ws.event.open = {
            print("opened")
        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                let msg = WebsocketMessage(message: text)
                let content = UNMutableNotificationContent()
                
                content.title = msg.title
                content.body = msg.body
                content.sound = UNNotificationSound.default()
                
                // Deliver the notification in five seconds.
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "Distracting", content: content, trigger: trigger)
                
                // Schedule the notification.
                let center = UNUserNotificationCenter.current()
                center.add(request) { (error) in
                    
                }
            }
        }
    }
    
    func getControllerFromStoryboard(
        storyboard:String,
        controller:String,
        modifier:((UIViewController) -> Void)?
        ) -> UIViewController{
        
        let storyboard = UIStoryboard(name:storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: controller)
        
        if let m = modifier {
            m(controller)
        }
        return controller
    }
    
    func present(
        presenter:UIViewController,
        storyboard:String,
        controller:String,
        modifier:((UIViewController) -> Void)?,
        completion:(() -> Void)?
        ){
        
        let presenting = getControllerFromStoryboard(
            storyboard: storyboard,
            controller: controller,
            modifier: modifier
        )
        
        presenter.present(presenting, animated: true, completion: completion)
    }
    
    func redirect(
        delegate:AppDelegate,
        storyboard:String,
        controller:String,
        modifier:((UIViewController) -> Void)?) {
        
        
        let redirect = getControllerFromStoryboard(
            storyboard: storyboard,
            controller: controller,
            modifier: modifier
        )
        
        delegate.window = delegate.window ?? UIWindow(frame: UIScreen.main.bounds)
        if let window = delegate.window {
            
            if let root = window.rootViewController {
                present(
                    presenter: root,
                    storyboard: storyboard,
                    controller: controller,
                    modifier: modifier,
                    completion: nil
                )
                return
            }
            
            window.rootViewController = redirect
            window.makeKeyAndVisible()
        
        }
    }
    
    func viewedOnboard(){
        UserDefaults.standard.set(true,forKey:"viewed_onboard")
    }
    
    func isViewedOnboard()->Bool{
        if let viewed = UserDefaults.standard.value(forKey: "viewed_onboard") {
            return viewed as! Bool
        }
        return false
    }
    
    var isOnline:Bool {
        get {
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            
            let isReachable = flags == .reachable
            let needsConnection = flags == .connectionRequired
            
            return isReachable && !needsConnection

        }
    }
    
}
