//
//  TimerLabel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

final class TimerLabel: UILabel {

    // MARK: - Private Properties

    private var timer: Timer?
    private var startTime: Date?
    private var endDate: Date?

    // MARK: - Public Methods

    func setupTimer(endDate: Date) {
        stopTimer()
        startTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(fire),
                                     userInfo: nil,
                                     repeats: true)
        
        self.endDate = endDate
    }

    func stopTimer() {
        timer?.invalidate()
        
    }
}

// MARK: - Private Methods

private extension TimerLabel {

    @objc func fire() {
        guard let startTime = startTime, let endDate = endDate else { return }

        self.endDate = endDate.add(type: .second, value: -1)
        let userCalendar = Calendar.current
        let timeLeft = userCalendar.dateComponents([.hour, .minute, .second],
                                                   from: startTime,
                                                   to: endDate)
        if let hours = timeLeft.hour, let minutes = timeLeft.minute, let seconds = timeLeft.second {
            guard hours != 0 || minutes != 0 || seconds != 0 else {
                text = "00:00:00"
                timer?.invalidate()
                return
            }

            let hoursString = hours < 10 ? "0\(hours)" : "\(hours)"
            let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
            let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"

            text = hoursString + ":" + minutesString + ":" + secondsString
        }
    }
}
