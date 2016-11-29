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
    
    let fullTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }()
    
    var session:Session?{
        didSet{
            if let session = session {
                goalLabel.text = session.goal
                statusImageView.image = UIImage(named: "Checked-50")
                if !session.is_success {
                    statusImageView.image = #imageLiteral(resourceName: "Cancel-50")
                }
                
                var components = DateComponents()
                components.second = Int(session.duration)
                
                durationLabel.text = fullTimeFormatter.string(from: components)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse(){
        statusImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
