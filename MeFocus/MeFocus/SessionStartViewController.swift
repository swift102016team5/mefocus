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

class SessionStartViewController: UIViewController {
    
    @IBOutlet weak var goalTextField: AutoCompleteGoal!
    @IBOutlet weak var timeSlider: CircularSlider!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var hourLabel: HThreeLabel!
    @IBOutlet weak var minuteLabel: HThreeLabel!
    
    var userTargetTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalTextField.autoCompleteTextFieldDataSource = goalTextField
        goalTextField.autoCompleteGoalDelegate = self
        
        view.backgroundColor = UIColor.flatWhite
        initViews()
    }
    
    func textViewDidChange(textView: UITextView) { // Handle the text changes here
        print(textView.text); // the textView parameter is the textView where text was changed
    }
    
    var goal: String?
    var duration: Int?
    var maximumPauseDuration: Int?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        SessionsManager.unfinished?.finish()
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let sessionOngoingViewController = segue.destination as! SessionOngoingViewController
        do {
            try sessionOngoingViewController.session = SessionsManager.start (
                goal: goal ?? "Stay Focus",
                duration: duration ?? 0,
                maximPauseDuration: maximumPauseDuration ?? 0
            )
        }
        catch {
            print("Cannot save session \(error)")
        }
    }
    
    func initViews() {
        initTimeSlider()
        initLabels()
        
        startButton.isEnabled = false
    }
    
    func initTimeSlider() {
        timeSlider.trackColor = App.shared.theme.backgroundLighColor.withAlphaComponent(0.1)
        timeSlider.trackFillColor = App.shared.theme.backgroundDarkColor
        timeSlider.diskFillColor = App.shared.theme.backgroundLighColor.withAlphaComponent(0.2)
        timeSlider.endThumbStrokeColor = UIColor.flatGreen
        timeSlider.endThumbTintColor = UIColor.flatWhite
        timeSlider.endThumbStrokeHighlightedColor = UIColor.flatGreenDark
        
        timeSlider.maximumValue = 12 * 60 // 12h
        timeSlider.minimumValue = 0
        timeSlider.endPointValue = 0
        timeSlider.addTarget(self, action: #selector(updateTimerOnSliderChange), for: .valueChanged)
    }
    
    func initLabels() {
        minuteLabel.text = "0"
        hourLabel.text = "0"
    }
    
    func updateTimerOnSliderChange() {
        timeSlider.endPointValue.round()
        let totalMinutes = Int(timeSlider.endPointValue)
        let minutes = totalMinutes % 60
        let hours = totalMinutes / 60
        minuteLabel.text = "\(minutes)"
        hourLabel.text = "\(hours)"
        
        goal = goalTextField.text
        duration = totalMinutes * 60
        maximumPauseDuration = 10
        
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

