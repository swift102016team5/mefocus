//
//  Api.swift
//  MeFocus
//
//  Created by Hao on 11/28/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import AFNetworking

struct User {
    
    var nickname:String
    var picture:String
    var name:String
    
    init(dictionary:NSDictionary){
    
        nickname = dictionary["nickname"] as! String
        picture = dictionary["picture"] as! String
        name = dictionary["name"] as! String
    
    }
    
}

class Api: NSObject {

    private static var _shared:Api?
    
    static var shared:Api?{
        get {
            
            if _shared == nil {
                
                _shared = Api()
                
            }
            
            return _shared
        }
    }
    
    func fetch(name:String,completion:@escaping ([User]) -> ()){
    
        let url = URL(string: "https://mefocusgo.herokuapp.com/api/users?q=\(name)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10
        )
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task: URLSessionDataTask =
            session
                .dataTask(
                    with: request,
                    completionHandler:{
                        (dataOrNil,response,error) in
                        
                        if let data = dataOrNil {
                        
                            if let dictionary = try! JSONSerialization.jsonObject(with: data,options:[]) as? [NSDictionary] {

                                var users:[User] = []
                                
                                for item in dictionary {
                                    
                                    users.append(User(dictionary: item))
                                    
                                }
                                
                                completion(users)
                                
                            }
                            
                        }
                        
                    }
                )
        task.resume();
        
        
    }
    
}
