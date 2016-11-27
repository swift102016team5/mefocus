//
//  Recorder.swift
//  MeFocus
//
//  Created by Enta'ard on 11/27/16.
//  Copyright © 2016 Group5. All rights reserved.
//


// TODO: create a service class to provide funcs for SessionSettingTableViewController
import UIKit

class Recorder: NSObject {
    
    static func createRecorderCell(for tableView: UITableView, at indexPath: IndexPath, of controller: SessionSettingTableViewController) -> RecorderCell {
        let recorderCell = tableView.dequeueReusableCell(withIdentifier: "RecorderCell", for: indexPath) as! RecorderCell
        recorderCell.recordBtn.addTarget(controller, action: #selector(controller.onRecord(_:)), for: .touchUpInside)
        recorderCell.playBtn.addTarget(controller, action: #selector(controller.onPlay(_:)), for: .touchUpInside)
        recorderCell.stopBtn.addTarget(controller, action: #selector(controller.onStopRecording(_:)), for: .touchUpInside)
        recorderCell.deleteAllBtn.addTarget(controller, action: #selector(controller.onRemoveAll(_:)), for: .touchUpInside)
        return recorderCell
    }
    
}
