//
//  AutoCompleteGoal.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import AutoCompleteTextField

protocol AutoCompleteGoalDelegate {
    
    func onResignFirstResponder(suggestion:Suggestion)
    
    func onResignFirstResponder(goal:String)
}

class AutoCompleteGoal: AutoCompleteTextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     */
    
    var autoCompleteGoalDelegate:AutoCompleteGoalDelegate?
    
    override open func resignFirstResponder() -> Bool {

        let responder = super.resignFirstResponder()
        
        if let delegate = autoCompleteGoalDelegate {
            let goal:String = text ?? ""
            if let suggestion = SuggestionsManager.findByGoal(goal: goal){
                delegate.onResignFirstResponder(suggestion: suggestion)
                return responder
            }
            
            delegate.onResignFirstResponder(goal: goal)
            
        }
        
        return responder
    }
    
}

extension AutoCompleteGoal:AutoCompleteTextFieldDataSource {

    func autoCompleteTextFieldDataSource(_ autoCompleteTextField: AutoCompleteTextField) -> [String] {
        
        let suggestions = SuggestionsManager.all
        
        return suggestions.map({
            (suggestion:Suggestion) in
            
            if let name = suggestion.goal {
                return name
            }
            return ""
        })
    }
}
