//
//  UserLoginViewController.swift
//  MeFocus
//
//  Created by Hao on 11/19/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import Lock
import SimpleKeychain

class UserLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Auth.shared.check{
            (auth:Auth) in
            // Dont have profile
            if auth.profile == nil {
                let controller = A0Lock.shared().newLockViewController()
                controller?.onAuthenticationBlock = { maybeProfile, maybeToken in
                    // Do something with token  profile. e.g.: save them.
                    // Lock will not save these objects for you.
                    
                    // Don't forget to dismiss the Lock controller
                    guard let token = maybeToken else {
                        print("cannot get token")
                        return
                    }
                    
                    guard let profile = maybeProfile else {
                        print("cannot get profile")
                        return
                    }
                    
                    auth.token = token
                    auth.profile = profile

                    controller?.dismiss(animated: true, completion: nil)
                }
                A0Lock.shared().present(controller, from: self)
                return
            }
            // Already have profile 
            // Do some navigations ...
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
