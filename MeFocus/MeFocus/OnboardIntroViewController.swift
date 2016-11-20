//
//  OnboarIntroViewController.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class OnboardIntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        App.shared.viewedOnboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignup(_ sender: Any) {
        
        App.shared.present(
            presenter:self,
            storyboard:"User",
            controller:"UserLoginViewController",
            modifier:nil,
            completion:nil
        )
        
    }
    
    @IBAction func onSkip(_ sender: Any) {
        App.shared.present(
            presenter:self,
            storyboard:"Session",
            controller:"SessionStartViewController",
            modifier:nil,
            completion:nil
        )
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
