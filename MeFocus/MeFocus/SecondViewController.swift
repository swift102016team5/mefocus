//
//  SecondViewController.swift
//  MeFocus
//
//  Created by Nguyen Chi Thanh on 11/23/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var textLb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        textLb.text = "Sao hôm nay trời nóng quá vei, củ lạc giòn tan #_#"
        textLb.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let opacityAni = CABasicAnimation(keyPath: "opacity")
        opacityAni.fromValue = 0
        opacityAni.toValue = 1
        
        let moveAni = CABasicAnimation(keyPath: "transform.translation.y")
        moveAni.fromValue = -300
       
        
        let groupAni = CAAnimationGroup()
        groupAni.animations = [opacityAni,moveAni]
        groupAni.duration = 1
        textLb.layer.add(groupAni, forKey: nil)
    }
    
}
