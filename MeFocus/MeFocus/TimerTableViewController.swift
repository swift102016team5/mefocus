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
    let requestIdentifier = "ReturnRequest"
    let backgroundLimitTime = 10
    let gray = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    
    var timer: Timer?
    var backgroundTimer: Timer?
    var remainBackgroundTime = 0
    var isCountingTime = false
    var goalFailed = false
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var timeBeforePause: NSDate?
    var userTargetTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        addObservers()
    }
    
    @IBAction func onStartTimer(_ sender: UIButton) {
        operateTimer()
    }
    
    func updateTimerOnCountdown() {
        circularSlider.endPointValue -= 1 / 60
        let endPointValueInSec = circularSlider.endPointValue * 60
        var components = DateComponents()
        components.second = Int(endPointValueInSec)
        timerLabel.text = fullTimeFormatter.string(from: components)
        taskTimer.timeRemaining = endPointValueInSec
        if Int(endPointValueInSec) <= 0 {
            stopTimer()
            NSLog("You succeeded!!!")
            resetTimer()
        }
    }
    
    func updateTimerOnSliderChange() {
        circularSlider.endPointValue.round()
        var components = DateComponents()
        components.minute = Int(circularSlider.endPointValue)
        userTargetTime = components.minute!
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
    
    func operateTimer(notFromBackground: Bool = true) {
        // Reset / do nothing if timer <= 0
        guard Int(circularSlider.endPointValue) > 0 else {
            circularSlider.endPointValue = 0
            return
        }
        
        // If timer's counting, stop it
        guard !isCountingTime else {
            stopTimer()
            goalFailed = true
            return
        }
        
        // If app wake from background, check goalFailed
        if !notFromBackground {
            guard !goalFailed else {
                setStartButton(withState: true)
                return
            }
        }
        
        // Start timer
        
        goalFailed = false
        backgroundTimer?.invalidate()
        taskTimer.timerRun = circularSlider.endPointValue * 60
        isCountingTime = true
        circularSlider.isEnabled = false
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimerOnCountdown),
                                     userInfo: nil,
                                     repeats: true)
        setStartButton(withState: false)
        NSLog("User's target time: \(userTargetTime) minutes")
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
                NSLog(error.localizedDescription)
            }
        }

        
        startBackgroundCountdown()
    }
    
    func startBackgroundCountdown() {
        stopTimer()
        registerForBackgroundTask()
        
        // Background task
        remainBackgroundTime = backgroundLimitTime
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (backgroundTimer) in
            self.remainBackgroundTime = self.remainBackgroundTime - 1
            NSLog("Background time: \(self.remainBackgroundTime)")
            if self.remainBackgroundTime == 0 {
                NSLog("You failed your goal!!!")
                self.goalFailed = true
                backgroundTimer.invalidate()
                
                self.endBackgroundTask()
            }
        })
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended!")
        NSLog("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func registerForBackgroundTask() {
        NSLog("Background task started!")
        NSLog("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        // Register backgroundTask
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: returnNotification, expirationHandler: { () in
            self.endBackgroundTask()
        })
    }
    
    func initViews() {
        timerTableView.isScrollEnabled = false
        
        // Timer's unit is in minute
        circularSlider.maximumValue = 12 * 60
        circularSlider.minimumValue = 0
        circularSlider.endPointValue = 0
        circularSlider.addTarget(self, action: #selector(updateTimerOnSliderChange), for: .valueChanged)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerTableViewController.triggerNotification),
                                               name: NSNotification.Name(returnNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerTableViewController.operateTimer(notFromBackground:)),
                                               name: NSNotification.Name(enterForegroundNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerTableViewController.saveCurrentTime),
                                               name: NSNotification.Name(saveCurrentTimeNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TimerTableViewController.resumeTimer),
                                               name: NSNotification.Name(resumeTimerNotification),
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
    
    func saveCurrentTime() {
        guard isCountingTime else {
            return
        }
        
        timeBeforePause = NSDate()
        NSLog("Time before paused: \(timeBeforePause)")
        stopTimer()
    }
    
    func resumeTimer() {
        guard !goalFailed else {
            return
        }
        
        let currentTime = NSDate()
        NSLog("Time at resume: \(currentTime)")
        let interval = currentTime.timeIntervalSince(timeBeforePause! as Date) as Double
        let intervalInMin = interval / 60
        
        guard intervalInMin < Double(userTargetTime) else {
            NSLog("You succeeded!!!")
            resetTimer()
            return
        }

        circularSlider.endPointValue = circularSlider.endPointValue - CGFloat(intervalInMin)
        operateTimer()
    }
    
    func resetTimer() {
        circularSlider.endPointValue = 0
        timerLabel.text = "0h 0m 0s"
    }

}

extension TimerTableViewController: UNUserNotificationCenterDelegate {
    
    // Do sth on tap on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("Tapped in notification")
    }
    
    // This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NSLog("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == requestIdentifier {
            completionHandler([.alert,.sound,.badge])
        }
    }
}
