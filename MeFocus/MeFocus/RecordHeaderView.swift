//
//  RecordHeaderView.swift
//  MeFocus
//
//  Created by Enta'ard on 11/28/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class RecordHeaderView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
    }
    
    private func shareInit() {
        Bundle.main.loadNibNamed("RecordHeaderView", owner: self, options: nil)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
    }

}
