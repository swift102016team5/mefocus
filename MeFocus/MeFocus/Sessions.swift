//
//  Sessions.swift
//  MeFocus
//
//  Created by Hao on 11/18/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import CoreData

class Pause:NSManagedObject {
    
    @NSManaged var id:Int
    @NSManaged var pause_at:Int
    @NSManaged var continue_at:Int
    
}

class Session:NSManagedObject {
    
    @NSManaged var id:String
    @NSManaged var user_id:String
    @NSManaged var start_at:Int
    @NSManaged var maximum_pause_duration:Int
    @NSManaged var goal:String
    @NSManaged var total_pauses:Int
    @NSManaged var duration:Int
    @NSManaged var pauses:[Pause]
    
}

class Sessions: NSObject {

    static var last:Session?
    
    static func save(session:Session){
    
    }
    
    static func find(){
    
    }
    
    static func delete(session:Session){
    
    }
}