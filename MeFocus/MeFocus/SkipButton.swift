//
//  SkipButton.swift
//  MeFocus
//
//  Created by Hao on 11/26/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class SkipButton: UIButton {

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
        titleLabel?.font = UIFont(name: "Avenir Next Ultra Light", size: 16)!
    }
    
    @objc func didTouchUp(_ sender: Any){
        App.shared.redirect(
            delegate: UIApplication.shared.delegate as! AppDelegate,
            storyboard: "Session",
            controller: "SessionStartViewController",
            modifier:nil
        )
    }

}
