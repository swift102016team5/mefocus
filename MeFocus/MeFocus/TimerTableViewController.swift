//
//  TimerTableViewController.swift
//  MeFocus
//
//  Created by Enta'ard on 11/17/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import HGCircularSlider

struct taskTimer {
    static var timerRun: CGFloat = 0
    static var timeRemaining: CGFloat = 0
}
class TimerTableViewController: UITableViewController {

    @IBOutlet var timerTableView: UITableView!
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    let fullTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .dropAll
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        
        return formatter
    }()
    let timeInterval: CGFloat = 5
    
    var timer: Timer?
    var isCountingTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerTableView.isScrollEnabled = false
        
        circularSlider.maximumValue = 12 * 60
        circularSlider.minimumValue = 0
        circularSlider.endPointValue = 0
        circularSlider.addTarget(self, action: #selector(updateTimer), for: .valueChanged)
    }
    
    @IBAction func onStartTimer(_ sender: UIButton) {
        guard Int(circularSlider.endPointValue) > 0 else {
            circularSlider.endPointValue = 0
            return
        }
        
        guard !isCountingTime else {
            stopTimer()
            return
        }
        taskTimer.timerRun = circularSlider.endPointValue * 60
        isCountingTime = true
        circularSlider.isEnabled = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatePlayerUI), userInfo: nil, repeats: true)
        
        sender.setTitle("STOP", for: .normal)

    }
    
    
    func updatePlayerUI() {
        circularSlider.endPointValue -= 1 / 60
        let endPointValueInSec = circularSlider.endPointValue * 60
        var components = DateComponents()
        components.second = Int(endPointValueInSec)
        timerLabel.text = fullTimeFormatter.string(from: components)
        taskTimer.timeRemaining = endPointValueInSec
        if Int(endPointValueInSec) <= 0 {
            stopTimer()
            circularSlider.endPointValue = 0
        }
    }
    
    func updateTimer() {
        circularSlider.endPointValue.round()
        var components = DateComponents()
        components.minute = Int(circularSlider.endPointValue)
        timerLabel.text = fullTimeFormatter.string(from: components)
    }
    
    func stopTimer() {
        taskTimer.timerRun = 0
        taskTimer.timeRemaining = 0
        timer?.invalidate()
        circularSlider.isEnabled = true
        isCountingTime = false
        startButton.setTitle("START", for: .normal)
        
    }

}
