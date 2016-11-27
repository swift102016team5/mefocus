//
//  MonitorTableViewCell.swift
//  MeFocus
//
//  Created by Hao on 11/28/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class MonitorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: HTwoNormalLabel!

    @IBOutlet weak var nicknameLabel: NormalLabel!
    
    var user:User? {
        
        didSet{
            nameLabel.text = user?.name
            nicknameLabel.text = user?.nickname
            pictureImageView.setImageWith(URL(string:(user?.picture)!)!)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
