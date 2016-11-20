//
//  TimerTableViewController.swift
//  MeFocus
//
//  Created by Enta'ard on 11/17/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import HGCircularSlider
import UserNotifications

struct taskTimer {
    static var timerRun: CGFloat = 0
    static var timeRemaining: CGFloat = 0
    static var isStop = false
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
    let requestIdentifier = "ReturnRequest"
    let backgroundLimitTime = 10
    let gray = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    
    var timer: Timer?
    var backgroundTimer: Timer?
    var remainBackgroundTime = 0
    var isCountingTime = false
    var goalFailed = false
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        addObservers()
    }
    
    @IBAction func onStartTimer(_ sender: UIButton) {
        startTimer()
    }
    
    func updateTimerUI() {
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
        taskTimer.isStop = true
        timer?.invalidate()
        
        circularSlider.isEnabled = true
        isCountingTime = false
        setStartButton(withState: true)
    }
    
    func startTimer() {
        guard Int(circularSlider.endPointValue) > 0 else {
            circularSlider.endPointValue = 0
            return
        }
        
        guard !isCountingTime else {
            stopTimer()
            return
        }
        
        guard !goalFailed else {
            goalFailed = false
            setStartButton(withState: true)
            return
        }
        
        backgroundTimer?.invalidate()
        taskTimer.timerRun = circularSlider.endPointValue * 60
        isCountingTime = true
        circularSlider.isEnabled = false
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimerUI),
                                     userInfo: nil,
                                     repeats: true)
        
        setStartButton(withState: false)
    }
    
    func triggerNotification() {
        guard isCountingTime else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.body = "Please go back to your task in 10 sec"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

        
        startBackgroundCountdown()
    }
    
    func startBackgroundCountdown() {
        stopTimer()
        startBackgroundTask()
        
        remainBackgroundTime = backgroundLimitTime
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (backgroundTimer) in
            self.remainBackgroundTime = self.remainBackgroundTime - 1
            print("Background time: \(self.remainBackgroundTime)")
            if self.remainBackgroundTime == 0 {
                print("You failed your goal!!!")
                self.goalFailed = true
                backgroundTimer.invalidate()
                
                self.endBackgroundTask()
            }
        })
    }
    
    func endBackgroundTask() {
        print("Background task ended!")
        print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func startBackgroundTask() {
        print("Background task started!")
        print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        // Register backgroundTask
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: returnNotification, expirationHandler: { () in
            self.endBackgroundTask()
        })
    }
    
    func initViews() {
        timerTableView.isScrollEnabled = false
        
        circularSlider.maximumValue = 12 * 60
        circularSlider.minimumValue = 0
        circularSlider.endPointValue = 0
        circularSlider.addTarget(self, action: #selector(updateTimer), for: .valueChanged)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerTableViewController.triggerNotification),
                                               name: NSNotification.Name(returnNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerTableViewController.startTimer),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    func setStartButton(withState isStart: Bool) {
        if isStart {
            startButton.setTitle("START", for: .normal)
            startButton.setTitleColor(UIColor.white, for: .normal)
            return
        }
        
        startButton.setTitle("GIVE UP!", for: .normal)
        startButton.setTitleColor(gray, for: .normal)
    }

}

extension TimerTableViewController: UNUserNotificationCenterDelegate {
    
    // Do sth on tap on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Tapped in notification")
    }
    
    // This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == requestIdentifier {
            completionHandler([.alert,.sound,.badge])
        }
    }
}
