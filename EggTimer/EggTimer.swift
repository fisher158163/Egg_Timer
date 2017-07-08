//
//  EggTimer.swift
//  EggTimer
//
//  Created by Liyu on 2017/7/8.
//  Copyright © 2017年 liyu. All rights reserved.
//

import Foundation

//定义一个protocol
protocol EggTimerProtocol {
    //声明协议方法
    func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval)
    func timerHasFinished(_ timer: EggTimer)
}

//定义一个class
class EggTimer {
    var timer: Timer? = nil
    var startTime: Date?
    var duration: TimeInterval = 360     // default = 6 minutes  TimeInterval 实际上是 Double，意思为秒数
    var elapsedTime: TimeInterval = 0
    
    //timer停止
    var isStopped: Bool {
        return timer == nil && elapsedTime == 0
    }
    
    //timer暂停
    var isPaused: Bool {
        return timer == nil && elapsedTime > 0
    }
    
    //代理属性
    var delegate: EggTimerProtocol?
    
    
    dynamic func timerAction() {
        //1
        guard let startTime = startTime else {
            return
        }
        //2
        elapsedTime = -startTime.timeIntervalSinceNow
        
        //3 四舍五入整数值
        let secondRemaining = (duration - elapsedTime).rounded()
        
        //4
        if secondRemaining <= 0 {
            delegate?.timerHasFinished(self)
            resetTimer()
        } else {
            delegate?.timeRemainingOnTimer(self, timeRemaining: secondRemaining)
        }
    }
    
    //开始
    func startTimer() {
        startTime = Date()
        elapsedTime = 0
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
        timerAction()
    }
    //重新开始,继续
    func resumeTimer() {
        startTime = Date(timeIntervalSinceNow: -elapsedTime)
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
        timerAction()
    }
    
    //停止
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        timerAction()
    }
    
    //重置
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        
        startTime = nil
        duration = 360
        elapsedTime = 0
        
        timerAction()
    }
    
}
