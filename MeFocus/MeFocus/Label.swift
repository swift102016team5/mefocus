//
//  HOneLabel.swift
//  MeFocus
//
//  Created by Hao on 11/22/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

extension UIFont {
    func bold() -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits([.traitBold])
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func boldAndItalic() -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func italic() -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic])
        return UIFont(descriptor: descriptor!, size: 0)
    }
}

class HOneLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = font.withSize(30).bold()
    }

}

class HTwoLabel: UILabel {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = font.withSize(24).bold()
    }
    
}

class HThreeLabel: UILabel {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = font.withSize(18).bold()
    }
    
}

class HFourLabel: UILabel {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = font.withSize(12).bold()
    }
    
}

class HFourDarkLabel: HFourLabel {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = App.shared.theme.textDarkColor
    }
    
}


class NormalLabel: UILabel {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = font.withSize(16)
    }
    
}

class SmallLabel: UILabel {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = font.withSize(12)
    }
    
}
