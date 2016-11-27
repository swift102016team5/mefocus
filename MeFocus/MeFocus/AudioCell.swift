//
//  AudioCell.swift
//  MeFocus
//
//  Created by Enta'ard on 11/26/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class AudioCell: UITableViewCell {

    @IBOutlet weak var audioNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var url: URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
