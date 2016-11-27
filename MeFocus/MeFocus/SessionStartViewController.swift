//
//  SessionStartViewController.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import AutoCompleteTextField
import HGCircularSlider
import AVFoundation

class SessionStartViewController: UIViewController {
    
    let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    let sessionSettingIdentifier = "sessionSetting"
    let sessionOngoingIdentifier = "sessionOngoing"
    
    @IBOutlet weak var goalTextField: AutoCompleteGoal!
    @IBOutlet weak var timeSlider: CircularSlider!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var coachNameLabel: NormalLabel!
    var userTargetTime = 0
    
    var coach:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalTextField.autoCompleteTextFieldDataSource = goalTextField
        goalTextField.autoCompleteGoalDelegate = self
        initViews()
        
        if coach != nil{
            coachNameLabel.text = coach?.name
        }
        
    }
    
    func textViewDidChange(textView: UITextView) { // Handle the text changes here
        print(textView.text); // the textView parameter is the textView where text was changed
    }
    
    var goal: String?
    var duration: Int?
    var maximumPauseDuration = 10
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        SessionsManager.unfinished?.finish()
        
        let identifier = segue.identifier
        
        if identifier == sessionOngoingIdentifier {
            let sessionOngoingViewController = segue.destination as! SessionOngoingViewController
            do {
                if goal == "" || goal == nil {
                    goal = "Live it Real"
                }
                try sessionOngoingViewController.session = SessionsManager.start (
                    goal: goal!,
                    duration: duration ?? 0,
                    maximPauseDuration: maximumPauseDuration
                )
            }
            catch {
                print("Cannot save session \(error)")
            }
        }
        
        if identifier == sessionSettingIdentifier {
            let navigationController = segue.destination as! UINavigationController
            let sessionSettingTableViewController = navigationController.topViewController as! SessionSettingTableViewController
            sessionSettingTableViewController.delegate = self
            
            let backroundTimes = sessionSettingTableViewController.backgroundLimitTime
            for index in 0..<backroundTimes.count {
                if backroundTimes[index] == maximumPauseDuration {
                    sessionSettingTableViewController.selectedTimeLimitIndex = index
                }
            }
        }
        
    }
    
    func initViews() {
        initTimeSlider()
        initLabels()
        
        startButton.isEnabled = false
        settingButton.isEnabled = true
    }
    
    func initTimeSlider() {
        timeSlider.trackColor = UIColor.flatWhite.withAlphaComponent(0.7)
        timeSlider.trackFillColor = UIColor.flatWhite
        timeSlider.diskFillColor = UIColor.flatWhite.withAlphaComponent(0)
        timeSlider.endThumbStrokeColor = UIColor.flatWhite
        timeSlider.endThumbTintColor = App.shared.theme.backgroundDarkColor
        timeSlider.endThumbStrokeHighlightedColor = UIColor.flatWhite
        timeSlider.lineWidth = 2.5
        timeSlider.thumbLineWidth = 2.5
        timeSlider.thumbRadius = 12
        
        timeSlider.maximumValue = 12 * 60 // 12h
        timeSlider.minimumValue = 0
        timeSlider.endPointValue = 0
        timeSlider.addTarget(self, action: #selector(updateTimerOnSliderChange), for: .valueChanged)
    }
    
    func initLabels() {
        timeLabel.text = "00:00"
        goalTextField.textColor = App.shared.theme.backgroundDarkColor
    }
    
    func updateTimerOnSliderChange() {
        timeSlider.endPointValue.round()
        let totalMinutes = Int(timeSlider.endPointValue)
        var components = DateComponents()
        components.minute = totalMinutes
        timeLabel.text = timeFormatter.string(from: components)
        
        duration = totalMinutes * 60
        
        startButton.isEnabled = totalMinutes > 0
    }
    
}

extension SessionStartViewController: AutoCompleteGoalDelegate {
    
    func onResignFirstResponder(suggestion: Suggestion) {
        goal = suggestion.goal
    }
    
    func onResignFirstResponder(goal: String) {
        self.goal = goal
    }
    
}

extension SessionStartViewController: SessionSettingTableViewControllerDelegate {
    
    func sessionSettingTableViewController(_ tableViewController: UITableViewController, backgroundLimitTime: Int) {
        maximumPauseDuration = backgroundLimitTime
    }
    
}

