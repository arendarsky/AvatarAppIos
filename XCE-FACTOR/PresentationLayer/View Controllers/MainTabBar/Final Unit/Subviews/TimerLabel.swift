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
    private var endDate: Date?

    // MARK: - Public Methods

    func setupTimer(endDate: Date) {
        self.endDate = endDate
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(startTimer),
                                     userInfo: nil,
                                     repeats: false)
    }
}

// MARK: - Private Methods

private extension TimerLabel {
    @objc func startTimer() {
        guard let endDate = endDate else { return }

        let currentDate = Date()
        let userCalendar = Calendar.current
        let timeLeft = userCalendar.dateComponents([.day, .hour, .minute, .second],
                                                   from: currentDate,
                                                   to: endDate)
        if let hour = timeLeft.hour, let minute = timeLeft.minute, let seconds = timeLeft.second {
            text = "\(hour):\(minute):\(seconds)"
        }
    }
}
