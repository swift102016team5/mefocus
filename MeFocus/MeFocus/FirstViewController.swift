//
//  FirstViewController.swift
//  MeFocus
//
//  Created by Nguyen Chi Thanh on 11/23/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var textLb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        textLb.text = "Check face cái xem dư lào, lên zalo chém gió vs mí e gái cái đã :3"
        textLb.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let animatedText = CABasicAnimation(keyPath: "transform.scale")
        animatedText.fromValue = 0
        animatedText.toValue = 1
        
        let rotationText = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationText.fromValue = 0
        rotationText.toValue = 4 * M_PI
        
        let opacityText = CABasicAnimation(keyPath: "opacity")
        opacityText.fromValue = 0
        opacityText.toValue = 1
        let multiAni = CAAnimationGroup()
        multiAni.animations = [animatedText,rotationText,opacityText]
        multiAni.duration = 1
        textLb.layer.add(multiAni, forKey: nil)
        
    }

    

}
