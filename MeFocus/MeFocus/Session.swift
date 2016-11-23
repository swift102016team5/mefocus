//
//  Session.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import Foundation
import CoreData
import AVFoundation
import UIKit

extension Session {
    
    func isExceedMaxiumPause() -> Bool {
        return SessionsManager.isExceedMaxiumPause(session:self)
    }

    func isOver() -> Bool {
        let now = Int64(NSDate().timeIntervalSince1970)
        if start_at + duration >= now {
            return true
        }
        return false
    }
    
    func finish(){
        end_at = Int64(NSDate().timeIntervalSince1970)
        SessionsManager.reset()
        Storage.shared.save()
    }
    
}

enum SessionsManagerError:Error {
    case Unfinished
    case MaximumPauseDurationMustGreaterThanZero
}

class SessionsManager:NSObject {
    
    // Start new session , doing implicit checking if there is any unfinished session 
    // If satisfied , it will start new session and persisted to storage
    // Reset manager pauses count
    static func start(
        goal:String,
        duration:Int,
        maximPauseDuration:Int
    ) throws -> Session {
        
        if maximPauseDuration == 0 {
            throw SessionsManagerError.MaximumPauseDurationMustGreaterThanZero
        }
        
        if SessionsManager.unfinished == nil {
            SessionsManager.reset()
            let session = Session(data:[
                "goal":goal,
                "duration":duration,
                "maximum_pause_duration":maximPauseDuration
            ])
            Storage.shared.save()
            return session
        }
        throw SessionsManagerError.Unfinished
    }
    
    static var pauses:Int64 = 0

    static func reset(){
        SessionsManager.pauses = 0
    }
    
    static func alert() -> AVAudioPlayer?{
        if let asset = NSDataAsset(name:"cohangxom") {
            var player:AVAudioPlayer

            do {
                try player = AVAudioPlayer(data: asset.data, fileTypeHint:"mp3")
                player.volume = 1
                return player
            }
            catch {
                print("Cannot play notification \(error)")
            }
            
        }
        return nil
    }
    
    static func isExceedMaxiumPause(session:Session) -> Bool {
        return SessionsManager.pauses > session.maximum_pause_duration
    }

    
    // Get unfinished session , usefull for navigation 
    static var unfinished:Session? {
        get {
            
            let request = Storage.shared.request(entityName: "Session")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "end_at = 0")
            
            let sessions = Storage.shared.fetch(request: request) as! [Session]
            
            if sessions.count == 1 {
                if let unfinish = sessions.first {
                    
                    if unfinish.isExceedMaxiumPause() || unfinish.isOver() {
                        unfinish.finish()
                        return nil
                    }
                    
                    return unfinish
                }

            }
            
            return nil
        }
    }
    
    
}
