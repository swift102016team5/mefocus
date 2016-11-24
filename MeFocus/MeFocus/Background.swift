//
//  BackgroundUIView.swift
//  MeFocus
//
//  Created by Hao on 11/21/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import ChameleonFramework

class BackgroundUIView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // Theming when view is created by code aka not programmed
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = GradientColor(
            .topToBottom,
            frame: bounds,
            colors: [
                App.shared.theme.backgroundColor,
                App.shared.theme.backgroundDarkColor
            ]
        )
        tintColor = App.shared.theme.textColor
        
        let labels = subviews.flatMap{$0 as? UILabel}
        for label in labels {
            label.textColor = tintColor
        }
    }

}

class BackgroundLeftRightUIView: BackgroundUIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    // Theming when view is created by code aka not programmed
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = GradientColor(
            .leftToRight,
            frame: bounds,
            colors: [
                App.shared.theme.backgroundColor,
                App.shared.theme.backgroundDarkColor
            ]
        )
    }
    
}

class BackgroundRadialUIView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = GradientColor(
            .radial,
            frame: bounds,
            colors: [
                App.shared.theme.backgroundDarkColor.lighten(byPercentage: 0.12)!,
                App.shared.theme.backgroundDarkColor
            ]
        )
        tintColor = App.shared.theme.textColor
        
        let labels = subviews.flatMap{$0 as? UILabel}
        for label in labels {
            label.textColor = tintColor
        }
        layer.masksToBounds = true
        layer.cornerRadius = bounds.width / 2
    }
    
}

class BackgroundGradientGrayUIView:BackgroundUIView{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = GradientColor(
            .leftToRight,
            frame: bounds,
            colors: [
                .flatWhite,
                .flatWhiteDark
            ]
        )
    }
}

class BackgroundLighterUIView:BackgroundUIView{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = App.shared.theme.backgroundLighColor
    }
}

class BackgroundDarkerUIView:BackgroundUIView{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = App.shared.theme.backgroundDarkColor
    }
}
