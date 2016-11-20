//
//  SessionStartViewController.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class SessionStartViewController: UIViewController {

    @IBOutlet weak var goalTextField: AutoCompleteGoal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalTextField.autoCompleteTextFieldDataSource = goalTextField
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onGoalEditEnd(_ sender: Any) {
        print("END",goalTextField.text)
        if let goal = goalTextField.text {
            
            if let suggestion = SuggestionsManager.findByName(name: goal){
                print(suggestion)
            }
            
        }
    }
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(goalTextField.text)
        return
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigation = segue.destination as! UINavigationController
        let controller = navigation.topViewController as! SessionOngoingViewController
        do {
            try controller.session = SessionsManager.start(
                goal: "Relax",
                duration: 20000,
                maximPauseDuration: 10500
            )
        }
        catch {
            print("Cannot save session \(error)")
        }
    }
 

}
