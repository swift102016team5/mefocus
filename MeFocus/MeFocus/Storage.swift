//
//  Storage.swift
//  MeFocus
//
//  Created by Hao on 11/19/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import CoreData

extension NSManagedObject {
    
    convenience init(data:NSDictionary = [:]){
        self.init(context: Storage.shared.context)
        assign(data:data)
    }
    
    func assign(data:NSDictionary){
        
        for (key,value) in data {
            
            setValue(value, forKey: key as! String)
            
        }
        
    }
    
}

class Storage: NSObject {

    static private var _shared:Storage?
    
    static var shared:Storage {
        
        get {
            if self._shared == nil {
                self._shared = Storage()
            }
            return self._shared!
        }
    
    }
    
    var context:NSManagedObjectContext {
        get {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        }
    }
    
    func request(entityName:String) ->NSFetchRequest<NSFetchRequestResult>{
        return NSFetchRequest<NSFetchRequestResult>(entityName:entityName)
    }
    
    func fetch(request:NSFetchRequest<NSFetchRequestResult>)->[Any]{
        do {
            let entities = try context.fetch(request)
            return entities
        }
        catch {
            print("Cannot fetch data")
        }
        return []
    }
    
    func save(){
        do {
            try context.save()
        }
        catch {
            print("Cannot save the context \(error)")
        }
    }
    
}
