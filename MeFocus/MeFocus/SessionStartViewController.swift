//
//  SessionStartViewController.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import AutoCompleteTextField

class SessionStartViewController: UIViewController {

    @IBOutlet weak var goalTextField: AutoCompleteGoal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalTextField.autoCompleteTextFieldDataSource = goalTextField
        goalTextField.autoCompleteGoalDelegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
    }

    var goal:String?
    var duration:Int?
    var maximumPauseDuration:Int?
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigation = segue.destination as! UINavigationController
        let controller = navigation.topViewController as! SessionOngoingViewController
        do {
            
            try controller.session = SessionsManager.start(
                goal: goal ?? "",
                duration: duration ?? 0,
                maximPauseDuration: maximumPauseDuration ?? 0
            )
        }
        catch {
            print("Cannot save session \(error)")
        }
    }
 

}

extension SessionStartViewController:AutoCompleteGoalDelegate {
    
    func onResignFirstResponder(suggestion:Suggestion){
        goal = suggestion.goal
    }
    
    func onResignFirstResponder(goal:String){
        self.goal = goal
    }
    
}

