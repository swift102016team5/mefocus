//
//  Suggestions.swift
//  MeFocus
//
//  Created by Hao on 11/19/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import CoreData

class Suggestion:NSManagedObject {
    
    @NSManaged var goal:String
    @NSManaged var duration:Int
    @NSManaged var min_pauses:Int
    
}

class Suggestions: NSObject {
    

    static func fetch(){
    
    }
    
    static func fetch(user:Bool){
    
    }
    
}
