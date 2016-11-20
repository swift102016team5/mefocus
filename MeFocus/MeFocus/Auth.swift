//
//  Auth.swift
//  MeFocus
//
//  Created by Hao on 11/19/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import Lock
import SimpleKeychain

class Auth: NSObject {

    static private var _shared:Auth?
    
    static var shared:Auth{
        
        get {
            if self._shared == nil {
                self._shared = Auth()
            }
            return self._shared!
        }
        
    }
    
    var profile:A0UserProfile? {
        didSet {
            if let p = profile {
                keychain.setData(
                    NSKeyedArchiver.archivedData(withRootObject: p),
                    forKey: "profile"
                )
            }
        }
    }
    
    var token:A0Token? {
        didSet {
            if let t = token {
                keychain.setString(t.idToken, forKey: "idToken")
            }
        }
    }
    
    var keychain:A0SimpleKeychain
    var client:A0APIClient
    
    override init() {
        keychain = A0SimpleKeychain(service: "Auth0")
        client = A0Lock.shared().apiClient()
    }
    
    func check(completion:@escaping ((Auth)->Void)){
        
        if profile != nil {
            completion(self)
            return
        }
        
        guard let idToken = keychain.string(forKey: "idToken") else {
            completion(self)
            return
        }
        
        client.fetchUserProfile(
            withIdToken: idToken,
            success: { profile in
                // Our idToken is still valid...
                // We store the fetched user profile
                self.profile = profile
                completion(self)
            },
            failure: { error in
                self.keychain.clearAll()
                completion(self)
            }
        )
        
    }
    
}
