//
//  MockTimerService.swift
//  UpnetixLocalizer_Tests
//
//  Created by Aleksandar Sergeev Petrov on 30.09.20.
//  Copyright © 2020 Upnetix. All rights reserved.
//

import Foundation
@testable import Flexx

final class MockTimerService: TimerService {
    private var eventHandler: (() -> Void)?

    var isRuning: Bool = false

    func start(_ eventHandler: @escaping TimerEventHandler) {
        self.eventHandler = eventHandler
        isRuning = true
    }

    func stop() {
        isRuning = false
    }

    func elapseTime() {
        eventHandler?()
    }

}
