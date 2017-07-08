//
//  ViewController.swift
//  EggTimer
//
//  Created by Liyu on 2017/7/7.
//  Copyright © 2017年 liyu. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var timeLeftField: NSTextField!
    
    @IBOutlet weak var eggImageView: NSImageView!
    
    @IBOutlet weak var startButton: NSButton!
    
    @IBOutlet weak var stopButton: NSButton!
    
    @IBOutlet weak var resetButton: NSButton!
    
    var eggTimer = EggTimer()
    
    var prefs = Preferences()
    
    //播放声音
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eggTimer.delegate = self
        setupPrefs()
        
    }
    //开始按钮
    @IBAction func startButtonClicked(_ sender: Any) {
        if eggTimer.isPaused {
            eggTimer.resumeTimer()
        } else {
            eggTimer.duration = prefs.selectedTime
            eggTimer.startTimer()
        }
        configureButtonsAndMenus()
        prepareSound()
    }
    //停止按钮
    @IBAction func stopButtonClicked(_ sender: Any) {
        eggTimer.stopTimer()
        configureButtonsAndMenus()
        soundPlayer?.stop()
    }
    //重置按钮
    @IBAction func resetButtonClicked(_ sender: Any) {
        eggTimer.resetTimer()
        updateDisplay(for: prefs.selectedTime)
        configureButtonsAndMenus()
        soundPlayer?.stop()
    }
    
    // MARK: - IBActions - menus
        @IBAction func startTimerMenuItemSelected(_ sender: Any) {
        startButtonClicked(sender)
    }
    
    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
        stopButtonClicked(sender)
    }
    
    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
        resetButtonClicked(sender)
    }
    
    override var representedObject: Any? {
        didSet {
        
        }
    }
    
    //计算按钮是否可点
    func configureButtonsAndMenus() {
        let enableStart: Bool
        let enableStop: Bool
        let enableReset: Bool
        
        if eggTimer.isStopped {
            enableStart = true
            enableStop = false
            enableReset = false
        } else if eggTimer.isPaused{
            enableStart = true
            enableStop = false
            enableReset = true
        } else {
            enableStart = false
            enableStop = true
            enableReset = false
        }
        startButton.isEnabled = enableStart
        stopButton.isEnabled = enableStop
        resetButton.isEnabled = enableReset
        
        //顶部菜单按钮可用与否
        if let appDelegate = NSApplication.shared().delegate as? AppDelegate {
            appDelegate.enableMenus(start: enableStart, stop: enableStop, reset: enableReset)
        }
    }
    
}

//代理方法
extension ViewController: EggTimerProtocol {
        
        func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval) {
            updateDisplay(for: timeRemaining)
    }
    
        func timerHasFinished(_ timer: EggTimer) {
            updateDisplay(for: 0)
            playSound()
    }
}

//给ViewController扩展方法
extension ViewController {
    func updateDisplay(for timeRemaining: TimeInterval) {
        timeLeftField.stringValue = textToDisplay(for: timeRemaining)
        eggImageView.image = imageToDisplay(for: timeRemaining)
        
    }
    
    private func textToDisplay(for timeRemaining: TimeInterval) ->String {
        if timeRemaining == 0 {
            return "Done!"
        }
        let minutesRemaining = floor(timeRemaining / 60)
        let secondsRemaining = timeRemaining - (minutesRemaining * 60)
        let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
        let timeRemainingDisplay = "\(Int(minutesRemaining)):\(secondsDisplay)"
        return timeRemainingDisplay
    }
    
    private func imageToDisplay(for timeRemaining: TimeInterval) ->NSImage? {
        let percentageComplete = 100 - (timeRemaining / prefs.selectedTime * 100)
        if eggTimer.isStopped {
            let stoppedImageName = (timeRemaining == 0) ? "100":"stopped"
            return NSImage(named: stoppedImageName)
        }
        
        let imageName: String
        switch percentageComplete {
        case 0..<25:
            imageName = "0"
        case 25..<50:
            imageName = "25"
        case 50..<75:
            imageName = "50"
        case 75..<100:
            imageName = "75"
        default:
            imageName = "100"
        }
        return NSImage(named: imageName)
    }
}

extension ViewController {
    // MARK: - Preferences
    func setupPrefs() {
        updateDisplay(for: prefs.selectedTime)
        
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil,
                                               queue: nil) {
                                                (notification) in
                                                self.checkForResetAfterPrefsChange()
        }
    }
    
    func updateFromPrefs() {
        self.eggTimer.duration = self.prefs.selectedTime
        self.resetButtonClicked(self)
    }
    
    func checkForResetAfterPrefsChange() {
        if eggTimer.isPaused || eggTimer.isStopped {
            updateFromPrefs()
        } else {
            let alert = NSAlert()
            alert.messageText = "Reset timer with the new settings?"
            alert.informativeText = "This will stop your current timer!"
            alert.alertStyle = .warning
            
            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == NSAlertFirstButtonReturn {
                self.updateFromPrefs()
            }
        }
    }
}

extension ViewController {
    // MARK: - Sound
    
    func prepareSound() {
        guard let audioFileUrl = Bundle.main.url(forResource: "ding", withExtension: "mp3") else {
            return
        }
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print("Sound player not available: \(error)")
        }
    }
    
    func playSound() {
        soundPlayer?.play()
        //numberOfLoops = -1为无限循环
        soundPlayer?.numberOfLoops = -1
    }
}





