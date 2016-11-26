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
    
    @objc func sessionSettingTableViewController(_ tableViewController: UITableViewController, backgroundLimitTime: Int)
    
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
    var audioList = [URL]()
    var numberOfAudio = 0
    var recordingCell: AudioCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTable.dataSource = self
        settingTable.delegate = self
        settingTable.rowHeight = UITableViewAutomaticDimension
        settingTable.estimatedRowHeight = 100
        
        setSessionPlayback()
        askForNotifications()
        checkHeadphones()
        // set the recordings array
        listRecordings()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func onBack(_ sender: UIBarButtonItem) {
        delegate?.sessionSettingTableViewController(self, backgroundLimitTime: backgroundLimitTime[selectedTimeLimitIndex])
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
            return numberOfAudio + 1
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
            let timeLimitLabel = backgroundTimeCell.timeLimitLabel
            
            timeLimitLabel?.text = limitTimeStr[row]
            timeLimitLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17)
            backgroundTimeCell.accessoryType = (row == selectedTimeLimitIndex) ? .checkmark : .none
            return backgroundTimeCell
        case 1:
            if row < numberOfAudio {
                let audioCell = tableView.dequeueReusableCell(withIdentifier: "AudioCell") as! AudioCell
                return audioCell
            }
            
            let recorderCellIndexPath = IndexPath(row: numberOfAudio, section: 1)
            let recorderCell = createRecorderCell(for: tableView, at: recorderCellIndexPath)
            return recorderCell
        default:
            return UITableViewCell()
        }
    }
    
    private func createRecorderCell(for tableView: UITableView, at indexPath: IndexPath) -> RecorderCell {
        let recorderCell = tableView.dequeueReusableCell(withIdentifier: "RecorderCell", for: indexPath) as! RecorderCell
        recorderCell.recordBtn.addTarget(self, action: #selector(onRecord(_:)), for: .touchUpInside)
        recorderCell.playBtn.addTarget(self, action: #selector(onPlay(_:)), for: .touchUpInside)
        recorderCell.stopBtn.addTarget(self, action: #selector(onStop(_:)), for: .touchUpInside)
        recorderCell.deleteAllBtn.addTarget(self, action: #selector(onRemoveAll(_:)), for: .touchUpInside)
        return recorderCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row != selectedTimeLimitIndex {
                let selectedIndexpath = IndexPath(row: selectedTimeLimitIndex, section: 0)
                settingTable.cellForRow(at: selectedIndexpath)?.accessoryType = .none
                settingTable.cellForRow(at: indexPath)?.accessoryType = .checkmark
                selectedTimeLimitIndex = indexPath.row
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 20, y: 0, width: tableView.bounds.width, height: 50)
        headerLabel.font = UIFont(name: "Avenir Book", size: 20)
        headerLabel.textColor = UIColor.flatGray
        switch section {
        case 0:
            headerLabel.text = "Background Time Limit"
        case 1:
            headerLabel.text = "Record Your Message"
        default:
            break
        }
        
        let headerView = UIView()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    func onRecord(_ sender: UIButton!) {
        if player != nil && player.isPlaying {
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            sender.setTitle("Pause", for:UIControlState())
            numberOfAudio = numberOfAudio + 1
            settingTable.reloadSections([1], with: .automatic)
            recordWithPermission(true)
            return
        }
        
        if let recorder = recorder, recorder.isRecording {
            print("pausing")
            recorder.pause()
            sender.setTitle("Continue", for:UIControlState())
            
        } else {
            print("recording")
            sender.setTitle("Pause", for:UIControlState())
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
            // if you want to draw some graphics...
            //var apc0 = recorder.averagePowerForChannel(0)
            //var peak0 = recorder.peakPowerForChannel(0)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
    }
    
    // MARK: - Recording part
    
    func onRemoveAll(_ sender: AnyObject) {
        deleteAllRecordings()
    }
    
    func onStop(_ sender: UIButton) {
        print("stop")
        
        recorder?.stop()
        player?.stop()
        meterTimer.invalidate()
        
        let recorderCell = settingTable.cellForRow(at: IndexPath(row: numberOfAudio, section: 1)) as! RecorderCell
        recorderCell.recordBtn.setTitle("Record", for: .normal)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
//            playButton.isEnabled = true
//            stopButton.isEnabled = false
//            recordButton.isEnabled = true
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
        
        //recorder = nil
    }
    
    func onPlay(_ sender: UIButton) {
        setSessionPlayback()
        play()
    }
    
    func play() {
        var url: URL?
        if self.recorder != nil {
            url = self.recorder?.url
        } else {
            url = self.soundFileURL!
        }
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
    }
    
    
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
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
                    let recordingIndexPath = IndexPath(row: self.numberOfAudio - 1, section: 1)
                    self.recordingCell = self.settingTable.cellForRow(at: recordingIndexPath) as? AudioCell
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target:self,
                                                           selector:#selector(SessionSettingTableViewController.updateAudioMeter(_:)),
                                                           userInfo:nil,
                                                           repeats:true)
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
                    listRecordings()
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
    
    func askForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(SessionSettingTableViewController.background(_:)),
                                               name:NSNotification.Name.UIApplicationWillResignActive,
                                               object:nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(SessionSettingTableViewController.foreground(_:)),
                                               name:NSNotification.Name.UIApplicationWillEnterForeground,
                                               object:nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(SessionSettingTableViewController.routeChange(_:)),
                                               name:NSNotification.Name.AVAudioSessionRouteChange,
                                               object:nil)
    }
    
    func background(_ notification:Notification) {
        print("background")
    }
    
    func foreground(_ notification:Notification) {
        print("foreground")
    }
    
    
    func routeChange(_ notification:Notification) {
        print("routeChange \((notification as NSNotification).userInfo)")
        
        if let userInfo = (notification as NSNotification).userInfo {
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
    }
    
    func checkHeadphones() {
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    func listRecordings() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            self.audioList = urls.filter({(name: URL) -> Bool in
                return name.lastPathComponent.hasSuffix("m4a")
            })
            numberOfAudio = audioList.count
            
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("something went wrong listing recordings")
        }
    }

}

// MARK: AVAudioRecorderDelegate
extension SessionSettingTableViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        print("finished recording \(flag)")
//        stopButton.isEnabled = false
//        playButton.isEnabled = true
//        recordButton.setTitle("Record", for:UIControlState())
        
        // iOS8 and later
        let alert = UIAlertController(title: "Recorder",
                                      message: "Finished Recording",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: {action in
            print("keep was tapped")
            self.listRecordings()
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
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
    }
    
}

// MARK: AVAudioPlayerDelegate
extension SessionSettingTableViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
//        recordButton.isEnabled = true
//        stopButton.isEnabled = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
}