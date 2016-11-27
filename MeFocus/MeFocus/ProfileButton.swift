//
//  ProfileButton.swift
//  MeFocus
//
//  Created by Hao on 11/27/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class ProfileButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(
            self,
            action: #selector(self.didTouchUp),
            for:UIControlEvents.touchUpInside
        )
    }
    
    @objc func didTouchUp(_ sender: Any){
        App.shared.redirect(
            delegate: UIApplication.shared.delegate as! AppDelegate,
            storyboard: "User",
            controller: "UserLoginViewController",
            modifier:nil
        )
    }
    
}
