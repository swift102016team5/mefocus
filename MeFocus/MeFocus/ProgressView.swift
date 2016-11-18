//
//  ProgressView.swift
//  MeFocus
//
//  Created by Nguyen Chi Thanh on 11/18/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setFillColor(UIColor.green.cgColor)
        
        context?.beginPath()
        context?.move(to: CGPoint(x: 50, y: 50))
        
        context?.addArc(center: CGPoint(x: 50, y: 50), radius: 40, startAngle: 0, endAngle: (1.00001 - progress) * 2.0 * CGFloat(M_PI), clockwise: true)
        context?.fillPath()
        
    }
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
}


