//
//  SessionOngoingViewController.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import HGCircularSlider
import UserNotifications

class SessionOngoingViewController: UIViewController {
    
    let fullTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }()
    let requestIdentifier = "ReturnRequest"
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: CircularSlider!
    @IBOutlet weak var goalLabel: UILabel!
    
    var session: Session? {
        didSet {
            // Setup some infomation
            userTargetTime = Int((session?.duration)!)
            backgroundLimitTime = Int((session?.maximum_pause_duration)!)
        }
    }
    var timer: Timer?
    var backgroundTimer: Timer?
    var backgroundLimitTime = 10
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
        runTimer()
    }
    
    @IBAction func onGiveUp(_ sender: UIButton) {
        stopTimer()
        dismiss(animated: true, completion: nil)
    }
    
    func initViews() {
        initTimeSlider()
        initLabels()
    }
    
    func initTimeSlider() {
        timeSlider.trackColor = UIColor.flatOrange
        timeSlider.trackFillColor = UIColor.flatWhite
        timeSlider.diskFillColor = UIColor.flatWhite
        timeSlider.diskColor = UIColor.flatWhite
        timeSlider.endThumbStrokeColor = UIColor.flatWhite.withAlphaComponent(0)
        timeSlider.endThumbTintColor = UIColor.flatWhite.withAlphaComponent(0)
        timeSlider.endThumbStrokeHighlightedColor = UIColor.flatWhite.withAlphaComponent(0)
        timeSlider.lineWidth = 3
        timeSlider.thumbLineWidth = 2.5
        timeSlider.thumbRadius = 12
        
        timeSlider.isEnabled = false
        timeSlider.maximumValue = CGFloat(userTargetTime)
        timeSlider.minimumValue = 0
        timeSlider.endPointValue = timeSlider.maximumValue
    }
    
    func initLabels() {
        var components = DateComponents()
        components.second = userTargetTime
        timeLabel.text = fullTimeFormatter.string(from: components)
        timeLabel.textColor = App.shared.theme.backgroundDarkColor
        
        goalLabel.textColor = App.shared.theme.backgroundDarkColor
        goalLabel.text = "\((session?.goal?.capitalized(with: Locale.autoupdatingCurrent))!)!"
    }
    
    func runTimer() {
        guard !goalFailed else {
            NSLog("You failed!!!")
            dismiss(animated: true, completion: nil)
            return
        }
        
        isCountingTime = true
        backgroundTimer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimerOnCountdown),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func resumeTimer() {
        guard !goalFailed else {
            NSLog("You failed!!!")
            dismiss(animated: true, completion: nil)
            return
        }
        
        let currentTime = NSDate()
        NSLog("Time at resume: \(currentTime)")
        let interval = currentTime.timeIntervalSince(timeBeforePause! as Date) as Double
        
        guard interval < Double(userTargetTime) else {
            NSLog("You succeeded!!!")
            return
        }
        
        timeSlider.endPointValue = timeSlider.endPointValue - CGFloat(interval)
        runTimer()
    }
    
    func stopTimer() {
        isCountingTime = false
        timer?.invalidate()
        SessionsManager.unfinished?.finish()
    }
    
    func saveCurrentTime() {
        guard isCountingTime else {
            return
        }
        
        timeBeforePause = NSDate()
        NSLog("Time before paused: \(timeBeforePause)")
        stopTimer()
    }
    
    func updateTimerOnCountdown() {
        timeSlider.endPointValue -= 1
        let endPointValueInSec = timeSlider.endPointValue
        var components = DateComponents()
        components.second = Int(endPointValueInSec)
        timeLabel.text = fullTimeFormatter.string(from: components)
        taskTimer.timeRemaining = endPointValueInSec
        if Int(endPointValueInSec) <= 0 {
            stopTimer()
            NSLog("You succeeded!!!")
        }
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
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
    
    func registerForBackgroundTask() {
        NSLog("Background task started!")
        NSLog("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        // Register backgroundTask
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: returnNotification, expirationHandler: { () in
            self.endBackgroundTask()
        })
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended!")
        NSLog("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SessionOngoingViewController.triggerNotification),
                                               name: NSNotification.Name(returnNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SessionOngoingViewController.runTimer),
                                               name: NSNotification.Name(enterForegroundNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SessionOngoingViewController.saveCurrentTime),
                                               name: NSNotification.Name(saveCurrentTimeNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SessionOngoingViewController.resumeTimer),
                                               name: NSNotification.Name(resumeTimerNotification),
                                               object: nil)
    }

}

extension SessionOngoingViewController: UNUserNotificationCenterDelegate {
    
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
            completionHandler([.alert, .sound, .badge])
        }
    }
    
}
