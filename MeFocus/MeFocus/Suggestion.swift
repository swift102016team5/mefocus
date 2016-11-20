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

    static private var _all:[Suggestion] = [
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
    
    static var all:[Suggestion]{
        get {
            return _all
        }
    }
    
    static func findByName(name:String) -> Suggestion? {
        
        return nil
    }
    
}
