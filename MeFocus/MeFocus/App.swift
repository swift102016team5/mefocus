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

/**
 ** Theme truck
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
        
        delegate.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = delegate.window {
            
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
