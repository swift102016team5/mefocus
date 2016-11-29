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
import AVFoundation

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
    var audioList = [URL]()
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        runTimer()
        RecorderAndPlayback.setSessionPlayback()
        loadAudioList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unregisterObserver()
    }
    
    @IBAction func onGiveUp(_ sender: UIButton) {
        stopTimer()
        showFailAlert()
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
            showFailAlert()
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
            showFailAlert()
            return
        }
        
        let currentTime = NSDate()
        NSLog("Time at resume: \(currentTime)")
        let interval = currentTime.timeIntervalSince(timeBeforePause! as Date) as Double
        
        guard interval < Double(userTargetTime) else {
            NSLog("You succeeded!!!")
            showSuccessAlert()
            return
        }
        
        timeSlider.endPointValue = timeSlider.endPointValue - CGFloat(interval)
        runTimer()
    }
    
    func pauseTimer() {
        timeBeforePause = NSDate()
        isCountingTime = false
        timer?.invalidate()
    }
    
    func stopTimer() {
        isCountingTime = false
        timer?.invalidate()
        session?.finish()
    }
    
    func saveCurrentTime() {
        guard isCountingTime else {
            return
        }
        
        pauseTimer()
        NSLog("Time before paused: \(timeBeforePause)")
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
            showSuccessAlert()
        }
    }
    
    func triggerNotification() {
        guard isCountingTime else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Don't let it tempt you!"
        content.body = "Please go back to your task in \(backgroundLimitTime) seconds"
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
        playAudio()
    }
    
    func startBackgroundCountdown() {
        NSLog("start background countdown at \(NSDate())")
        pauseTimer()
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
    
    func playAudio() {
        guard audioList.count > 0 else {
            player = SessionsManager.alert()
            player?.play()
            return
        }
        
        do {
            let index = randomIndex(inRange: audioList.count)
            player = try AVAudioPlayer(contentsOf: audioList[index])
            player?.delegate = self
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
        } catch let error as NSError {
            player = nil
            NSLog(error.localizedDescription)
        } catch {
            NSLog("AVAudioPlayer init failed")
        }
    }
    
    func loadAudioList() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            self.audioList = urls.filter({(name: URL) -> Bool in
                return name.lastPathComponent.hasSuffix("m4a")
            })
            
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        } catch {
            NSLog("something went wrong listing recordings")
        }
    }
    
    func registerForBackgroundTask() {
        NSLog("Background task started!")
        NSLog("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        UIApplication.shared.endBackgroundTask(backgroundTask)
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

    func registerObservers() {
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
    
    func unregisterObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(returnNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(enterForegroundNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(saveCurrentTimeNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(resumeTimerNotification), object: nil)
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

extension SessionOngoingViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            NSLog("\(e.localizedDescription)")
        }
    }
    
}

extension SessionOngoingViewController {
    
    func randomIndex(inRange range: Int) -> Int {
        let randomNumber: UInt32 = arc4random_uniform(UInt32(range))
        return Int(randomNumber)
    }
    
    func showFailAlert() {
        App.shared.ws.send(message:"Hey Tuan Anh| Hao is using his phone")
        SweetAlert().showAlert("Attempt failed!",
                               subTitle: "You almost finished it :(",
                               style: AlertStyle.error,
                               buttonTitle: "Retry",
                               buttonColor: UIColor.flatRed) { (isOtherButton) -> Void in
                                App.shared.present(
                                    presenter: self,
                                    storyboard: "Session",
                                    controller: "SessionStartNavigationController",
                                    modifier: nil,
                                    completion:nil
                                )
        }
    }
    
    func showSuccessAlert() {
        SweetAlert().showAlert("Congratulation!",
                               subTitle: "You lived it real! :)",
                               style: AlertStyle.success,
                               buttonTitle: "Go on",
                               buttonColor: UIColor.flatGreen) { (isOtherButton) -> Void in
                                App.shared.present(
                                    presenter: self,
                                    storyboard: "Session",
                                    controller: "SessionStartNavigationController",
                                    modifier: nil,
                                    completion:nil
                                )
        }
    }
    
}
