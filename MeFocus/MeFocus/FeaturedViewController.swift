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
    var timeEstimate: Double = 0
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        timeEstimate = Double(taskTimer.timerRun)

        initProgress()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !timer.isValid {
            progressview.removeFromSuperview()
            initProgress()
        }
       
    }


    func initProgress() {

        progress = 0
        let timeUsed = Double(taskTimer.timerRun - taskTimer.timeRemaining)

        progressview = ProgressView(frame: CGRect(x: view.center.x - 50, y: view.center.y - 50, width: 100, height: 100))
        progressview.backgroundColor = UIColor.white
        progressview.endAngle = CGFloat((timeUsed / timeEstimate) * 100 * 0.01)
        view.addSubview(progressview)
        
        let avatarView = UIImageView(frame: CGRect(x: 20, y: 20, width: 60, height: 60))
        avatarView.image = #imageLiteral(resourceName: "dog.jpg")
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 30
        progressview.addSubview(avatarView)
        timer = Timer.scheduledTimer(timeInterval: (Double(taskTimer.timeRemaining) / 100.0),
                             target: self,
                             selector: #selector(self.onTimer), userInfo: nil, repeats: true)
    }
    
    func onTimer() {
        progress += 0.01
        print("progress", progress)
        if progress > 1.001 {
            timer.invalidate()
        } else {
            progressview.progress = progress
        }
    }

    


}
