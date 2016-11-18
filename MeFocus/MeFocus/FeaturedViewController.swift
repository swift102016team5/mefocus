//
//  FeaturedViewController.swift
//  MeFocus
//
//  Created by Nguyen Chi Thanh on 11/18/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class FeaturedViewController: UIViewController {

    var progressview: ProgressView!
    var progress: CGFloat = 0.0
    
    
    /// Time Estimation Tasks
    var timeEstimate: Double = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        play()
        // Do any additional setup after loading the view.
    }


    func play() {
        progress = 0
        let w = UIScreen.main.bounds.width
        progressview = ProgressView(frame: CGRect(x: view.center.x - 50, y: view.center.y - 50, width: 100, height: 100))
        progressview.backgroundColor = UIColor.white
        view.addSubview(progressview)
        
        let avatarView = UIImageView(frame: CGRect(x: 20, y: 20, width: 60, height: 60))
        avatarView.image = #imageLiteral(resourceName: "dog.jpg")
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 30
        progressview.addSubview(avatarView)
        Timer.scheduledTimer(timeInterval: (timeEstimate / 100.0),
                             target: self,
                             selector: #selector(self.onTimer(_:)), userInfo: nil, repeats: true)
    }
    
    func onTimer(_ timer: Timer) {
        progress += 0.01
        print("progress", progress)
        if progress > 1.001 {
            timer.invalidate()
        } else {
            progressview.progress = progress
        }
    }

    


}
