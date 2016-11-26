//
//  RecorderCell.swift
//  MeFocus
//
//  Created by Enta'ard on 11/26/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class RecorderCell: UITableViewCell {

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var deleteAllBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
