//
//  SessionPickMonitorViewController.swift
//  MeFocus
//
//  Created by Hao on 11/28/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class SessionPickMonitorViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet var tableView: UITableView!
    
    var users:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        Api.shared?.fetch(
            name: "",
            completion: { (users:[User]) in
                self.users = users
                self.tableView.reloadData()
            })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            
            if identifier == "Choose" {
                
                let user = users[(tableView.indexPathForSelectedRow?.row)!]
                let navigation = segue.destination as! UINavigationController
                let start = navigation.topViewController as! SessionStartViewController
                
                start.coach = user
            
            }
            
        }
        
    }

}

extension SessionPickMonitorViewController:UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonitorTableViewCell") as! MonitorTableViewCell
        let user = users[indexPath.row]
        
        cell.user = user
        
        return cell
    }
    
}
