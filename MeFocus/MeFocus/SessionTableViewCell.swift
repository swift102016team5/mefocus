//
//  SessionTableViewCell.swift
//  MeFocus
//
//  Created by Hao on 11/22/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class SessionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusImageView: UIImageView!

    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    var session:Session?{
        didSet{
            if let session = session {
                goalLabel.text = session.goal
                if !session.is_success {
                    statusImageView.image = #imageLiteral(resourceName: "Cancel-50")
                }
//                durationLabel.text = session.duration
            }
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
