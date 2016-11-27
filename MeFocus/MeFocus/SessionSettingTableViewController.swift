//
//  SessionSettingTableViewController.swift
//  MeFocus
//
//  Created by Enta'ard on 11/25/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol SessionSettingTableViewControllerDelegate {
    
    @objc optional func sessionSettingTableViewController(_ tableViewController: UITableViewController, backgroundLimitTime: Int)
    
}

class SessionSettingTableViewController: UITableViewController {

    let limitTimeStr = ["10 seconds", "30 seconds", "1 minutes"]
    let backgroundLimitTime = [10, 30, 60]
    
    @IBOutlet var settingTable: UITableView!
    
    weak var delegate: SessionSettingTableViewControllerDelegate?
    var selectedTimeLimitIndex = 0
    
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer!
    var meterTimer: Timer!
    var soundFileURL: URL!
    var audioList = [URL]() // update at first start, or after recording and save (keep) audio file
    var numberOfAudio = 0 // = audioList.count. But when recording, numberOfAudio = audioList.count + 1
    var recordingCell: AudioCell? // new cell created while recording audio
    var recordHeader: RecordHeaderView!
    var playingCell: AudioCell?
    var willBeRecording = false
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTable.dataSource = self
        settingTable.delegate = self
        settingTable.rowHeight = UITableViewAutomaticDimension
        settingTable.estimatedRowHeight = 100
        settingTable.separatorColor = UIColor.flatGreen
        
        setSessionPlayback()
        // set the recordings array
        listRecordings()
    }

    @IBAction func onBack(_ sender: UIBarButtonItem) {
        delegate?.sessionSettingTableViewController!(self, backgroundLimitTime: backgroundLimitTime[selectedTimeLimitIndex])
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return limitTimeStr.count
        case 1:
            return numberOfAudio
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            let backgroundTimeCell = tableView.dequeueReusableCell(withIdentifier: "BackgroundTimeCell") as! BackgroundTimeCell
            backgroundTimeCell.tintColor = UIColor.flatGreenDark

            let timeLimitLabel = backgroundTimeCell.timeLimitLabel
            
            timeLimitLabel?.text = limitTimeStr[row]
            timeLimitLabel?.font = UIFont(name: "Avenir Next Ultra Light", size: 17)
            timeLimitLabel?.textColor = UIColor.flatBlack
            backgroundTimeCell.accessoryType = (row == selectedTimeLimitIndex) ? .checkmark : .none
            return backgroundTimeCell
        case 1:
            guard numberOfAudio > 0 else {
                return UITableViewCell()
            }
            
            let audioCell = tableView.dequeueReusableCell(withIdentifier: "AudioCell") as! AudioCell
            audioCell.statusLabel.textColor = UIColor.flatBlue
            audioCell.audioNameLabel.textColor = UIColor.flatBlack
            audioCell.statusLabel.font = UIFont(name: "Avenir Next Ultra Light", size: 18)
            audioCell.audioNameLabel.font = UIFont(name: "Avenir Next Ultra Light", size: 15)
            if willBeRecording, row == 0 {
                layoutRecordingAudioCell(of: audioCell)
                return audioCell
            }
            layoutAudioCell(of: audioCell, atRow: row)
            
            return audioCell
        default:
            return UITableViewCell()
        }
    }
    
    private func layoutRecordingAudioCell(of audioCell: AudioCell) {
        audioCell.statusLabel.isHidden = false
        audioCell.audioNameLabel.isHidden = true
        audioCell.playBtn.isHidden = true
        audioCell.deleteBtn.isHidden = true
    }
    
    private func layoutAudioCell(of audioCell: AudioCell, atRow row: Int) {
        audioCell.statusLabel.isHidden = true
        audioCell.audioNameLabel.isHidden = false
        audioCell.audioNameLabel.text = audioList[row].lastPathComponent
        audioCell.playBtn.isHidden = false
        audioCell.deleteBtn.isHidden = false
        audioCell.playBtn.setImage(#imageLiteral(resourceName: "Play-25"), for: .normal)
        audioCell.url = audioList[row]
        audioCell.playBtn.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
        audioCell.deleteBtn.addTarget(self, action: #selector(askToDelete(_:)), for: .touchUpInside)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            if row != selectedTimeLimitIndex {
                let selectedIndexpath = IndexPath(row: selectedTimeLimitIndex, section: 0)
                settingTable.cellForRow(at: selectedIndexpath)?.accessoryType = .none
                settingTable.cellForRow(at: indexPath)?.accessoryType = .checkmark
                selectedTimeLimitIndex = row
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = CGRect(x: 20, y: 0, width: tableView.bounds.width, height: 50)
        switch section {
        case 0:
            let headerView = UIView()
            let headerLabel = UILabel()
            headerLabel.frame = headerFrame
            headerLabel.font = UIFont(name: "Avenir Book", size: 20)
            headerLabel.textColor = UIColor.flatGreenDark
            headerLabel.text = "Background Time Limit"
            headerView.backgroundColor = UIColor.flatWhite
            headerView.addSubview(headerLabel)
            
            return headerView
        case 1:
            recordHeader = RecordHeaderView(frame: headerFrame)
            recordHeader.titleLabel.text = "Record Your Message"
            recordHeader.titleLabel.font = UIFont(name: "Avenir Book", size: 20)
            recordHeader.titleLabel.textColor = UIColor.flatGreenDark
            recordHeader.view.backgroundColor = UIColor.flatWhite
            recordHeader.stopBtn.isEnabled = false
            recordHeader.recordBtn.isEnabled = true
            recordHeader.recordBtn.addTarget(self, action: #selector(onRecord(_:)), for: .touchUpInside)
            recordHeader.stopBtn.addTarget(self, action: #selector(onStopRecording(_:)), for: .touchUpInside)
            return recordHeader
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func onRecord(_ sender: UIButton!) {
        if player != nil && player.isPlaying {
            player.stop()
            playingCell?.playBtn.setImage(#imageLiteral(resourceName: "Play-25"), for: .normal)
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            numberOfAudio = numberOfAudio + 1
            willBeRecording = true
            
            settingTable.beginUpdates()
            let newAudioCellIndexPath = IndexPath(row: 0, section: 1)
            settingTable.insertRows(at: [newAudioCellIndexPath], with: .automatic)
            settingTable.endUpdates()
            
            recordHeader.recordBtn.setImage(#imageLiteral(resourceName: "Circled Pause Filled-25"), for: .normal)
            recordHeader.stopBtn.isEnabled = true
            recordWithPermission(true)
            return
        }
        
        if let recorder = recorder, recorder.isRecording {
            print("pausing")
            recorder.pause()
            recordHeader.recordBtn.setImage(#imageLiteral(resourceName: "Play Record Filled-25"), for: .normal)
            
        } else {
            print("recording")
            recordHeader.recordBtn.setImage(#imageLiteral(resourceName: "Circled Pause Filled-25"), for: .normal)
            recordHeader.stopBtn.isEnabled = true
            recordWithPermission(false)
        }
    }
    
    func updateAudioMeter(_ timer: Timer) {
        guard let recordingCell = recordingCell else {
            return
        }
        
        if let recorder = recorder, recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let s = String(format: "%02d:%02d", min, sec)
            recordingCell.statusLabel.text = s
            recorder.updateMeters()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
    }
    
    // backup func
    func onRemoveAll(_ sender: AnyObject) {
        recordHeader.recordBtn.setImage(#imageLiteral(resourceName: "Add Record Filled-25"), for: .normal)
        player?.stop()
        deleteAllRecordings()
        listRecordings()
        settingTable.reloadSections([1], with: .automatic)
    }
    
    func onStopRecording(_ sender: UIButton) {
        print("stop")
        willBeRecording = false
        
        recorder?.stop()
        player?.stop()
        meterTimer.invalidate()
        
        recordHeader.recordBtn.setImage(#imageLiteral(resourceName: "Add Record Filled-25"), for: .normal)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
        
        //recorder = nil
    }
    
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd HH:mm:ss"
        let currentFileName = "\(format.string(from: Date())).m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        print("writing to soundfile url: '\(soundFileURL!)'")
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey:             NSNumber(value: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
            AVEncoderBitRateKey :      NSNumber(value:320000),
            AVNumberOfChannelsKey:     NSNumber(value:2),
            AVSampleRateKey :          NSNumber(value:44100.0)
        ]
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
    }
    
    func recordWithPermission(_ setup: Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool) -> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder?.record()
                    let recordingIndexPath = IndexPath(row: 0, section: 1)
                    self.recordingCell = self.settingTable.cellForRow(at: recordingIndexPath) as? AudioCell
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target: self,
                                                           selector: #selector(SessionSettingTableViewController.updateAudioMeter(_:)),
                                                           userInfo: nil,
                                                           repeats: true)
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func deleteAllRecordings() {
        let docsDir = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0]
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: docsDir)
            var recordings = files.filter( { (name: String) -> Bool in
                return name.hasSuffix("m4a")
            })
            for i in 0 ..< recordings.count {
                let path = docsDir + "/" + recordings[i]
                
                print("removing \(path)")
                do {
                    try fileManager.removeItem(atPath: path)
                    settingTable.reloadData()
                } catch let error as NSError {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }
    }
    
    func listRecordings() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            self.audioList = urls.filter({(name: URL) -> Bool in
                return name.lastPathComponent.hasSuffix("m4a")
            })
            numberOfAudio = audioList.count
            self.audioList.reverse()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("something went wrong listing recordings")
        }
    }
    
    func playAudio(_ sender: UIButton!) {
        // assign the new playingCell
        let newPlayingCell = sender.superview?.superview as? AudioCell
        
        if isPlaying, playingCell != newPlayingCell {
            playingCell?.playBtn.setImage(#imageLiteral(resourceName: "Play-25"), for: .normal)
            player?.stop()
            isPlaying = false
        }
        
        playingCell = newPlayingCell
        
        guard !isPlaying else {
            player?.stop()
            isPlaying = false
            playingCell?.playBtn.setImage(#imageLiteral(resourceName: "Play-25"), for: .normal)
            return
        }
        
        let url = playingCell?.url
        print("playing \(url)")
        
        do {
            playingCell?.playBtn.setImage(#imageLiteral(resourceName: "Stop-25"), for: .normal)
            self.isPlaying = true
            
            self.player = try AVAudioPlayer(contentsOf: url!)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    func askToDelete(_ sender: UIButton!) {
        player?.stop()
        isPlaying = false
        playingCell = nil
        
        let deleteCell = sender.superview?.superview as! AudioCell
        let indexPath = settingTable.indexPath(for: deleteCell)
        let row = indexPath?.row
        let alert = UIAlertController(title: "Delete",
                                      message: "Delete Recording \(audioList[row!].lastPathComponent)?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: { action in
                                        print("yes was tapped \(self.audioList[row!])")
                                        self.deleteRecording(self.audioList[row!])
        }))
        alert.addAction(UIAlertAction(title: "No",
                                      style: .default,
                                      handler: { action in
                                        print("no was tapped")
        }))
        self.present(alert, animated:true, completion:nil)
    }
    
    func deleteRecording(_ url:URL) {
        print("removing file at \(url.absoluteString)")
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: url)
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("error deleting recording")
        }
        
        DispatchQueue.main.async(execute: {
            self.listRecordings()
            self.settingTable.reloadData()
        })
    }

}

// MARK: AVAudioRecorderDelegate
extension SessionSettingTableViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording \(flag)")
        
        // iOS8 and later
        let alert = UIAlertController(title: "Recorder",
                                      message: "Finished Recording",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: {action in
            print("keep was tapped")
            self.listRecordings()
            self.settingTable.reloadSections([1], with: .automatic)
            self.recorder = nil
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in
            print("delete was tapped")
            self.recorder?.deleteRecording()
            self.recorder = nil
            
            self.listRecordings()
            self.settingTable.reloadSections([1], with: .automatic)
        }))
        self.present(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
}

// MARK: AVAudioPlayerDelegate
extension SessionSettingTableViewController : AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
        playingCell?.playBtn.setImage(#imageLiteral(resourceName: "Play-25"), for: .normal)
        isPlaying = false
        playingCell = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
}
