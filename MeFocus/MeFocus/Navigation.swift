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
        backgroundColor = App.shared.theme.backgroundDarkColor
        barTintColor = App.shared.theme.backgroundDarkColor
        tintColor = App.shared.theme.textColor
        titleTextAttributes = [
            NSForegroundColorAttributeName: App.shared.theme.textColor,
            NSFontAttributeName: UIFont(name: "Avenir Next Ultra Light",size:16)!
        ]
    }
}

class BackgroundClearNavigation: UINavigationBar {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        isTranslucent = true
        titleTextAttributes = [
            NSForegroundColorAttributeName:App.shared.theme.textColor,
            NSFontAttributeName: UIFont(name: "Avenir Next Ultra Light",size:16)!
        ]
        
        if let items = items {
            for item in items {
                
                if let left = item.leftBarButtonItem {
                    if let image = left.image {
                        left.image = image.withRenderingMode(.alwaysOriginal)
                    }
                }
                
            }
        }
    }
}

class BackgroundTabNavigation: UITabBar {
    
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
