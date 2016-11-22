//
//  UserProfileViewController.swift
//  MeFocus
//
//  Created by Hao on 11/21/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import AFNetworking

class UserProfileViewController: UIViewController {

    @IBOutlet weak var sessionsTableView: UITableView!
    
    var sessions:[Session] = []
    
    @IBOutlet weak var totalSessionLabel: HThreeLabel!
    
    @IBOutlet weak var totalTimeSpentLabel: HThreeLabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: HOneLabel!
    
    @IBOutlet weak var emailLabel: HFourLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profile = Auth.shared.profile {
            nameLabel.text = profile.nickname
            emailLabel.text = profile.email
            
            avatarImageView.setImageWith(profile.picture)
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
            avatarImageView.clipsToBounds = true
        }
        
        sessionsTableView.delegate = self
        sessionsTableView.dataSource = self
        sessionsTableView.estimatedRowHeight = 200
        sessionsTableView.rowHeight = UITableViewAutomaticDimension
        
        sessions = [
            Session(data:[
                "goal":"Ahihi",
                "duration":2000,
                "is_success":true
            ]),
            Session(data:[
                "goal":"Work",
                "duration":2000
            ]),
            Session(data:[
                "goal":"Relax",
                "duration":2000
            ]),
            Session(data:[
                "goal":"Homework !",
                "duration":2000
            ])
        ]
        
        totalSessionLabel.text = String(sessions.count)
        totalTimeSpentLabel.text = "40"
        
        sessionsTableView.reloadData()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserProfileViewController:UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = sessionsTableView.dequeueReusableCell(withIdentifier: "SessionTableViewCell") as! SessionTableViewCell
        
        cell.session = sessions[indexPath.row]
        
        return cell
        
    }
    

}
