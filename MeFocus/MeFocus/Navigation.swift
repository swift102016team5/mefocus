//
//  Navigation.swift
//  MeFocus
//
//  Created by Hao on 11/23/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import ChameleonFramework

class BackgroundNavigation: UINavigationBar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = App.shared.theme.backgroundColor
        barTintColor = App.shared.theme.backgroundColor
        tintColor = App.shared.theme.textColor
        titleTextAttributes = [NSForegroundColorAttributeName:App.shared.theme.textColor]
    }
}

class BackgroundTabNavigation:UITabBar {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = App.shared.theme.backgroundColor
        barTintColor = App.shared.theme.backgroundColor
        tintColor = App.shared.theme.textColor
        if let items = items {
            for item in items {
                item.image = item.image!.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
}
