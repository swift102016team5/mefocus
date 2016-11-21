//
//  Suggestion.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

extension Suggestion {

}

class SuggestionsManager:NSObject {

    static private var _defaults:[Suggestion] = [
        Suggestion(data:[
            "goal":"Relax",
            "duration":600,
            "min_pauses":20
        ]),
        Suggestion(data:[
            "goal":"Sleep",
            "duration":600,
            "min_pauses":20
        ]),
        Suggestion(data:[
            "goal":"Working",
            "duration":600,
            "min_pauses":20
        ]),
        Suggestion(data:[
            "goal":"Do home work!",
            "duration":600,
            "min_pauses":20
        ]),
    ]
    
    static private var _all:[Suggestion] = []
    
    static var all:[Suggestion]{
        get {
            if _all.count == 0 {
                let request = Storage.shared.request(entityName: "Suggestion")
                let suggestions = Storage.shared.fetch(request: request) as! [Suggestion]
                
                _all = (suggestions.count > 0) ? suggestions : _defaults
            }
            return _all
        }
    }
    
    static func findByGoal(goal:String) -> Suggestion? {
        return SuggestionsManager.all.filter{$0.goal?.lowercased() == goal.lowercased()}.first
    }
    
}
