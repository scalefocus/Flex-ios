//
//  TimerService.swift
//  Flexx
//
//  Created by Aleksandar Sergeev Petrov on 28.09.20.
//

import Foundation

typealias TimerEventHandler = @convention(block) () -> Void

protocol TimerService {
    func start(_ eventHandler: @escaping TimerEventHandler)
    func stop()
}

/// TimerService mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed
/// 
/// TimerService schedules a task that should be performed at specified repeat interval
final class TimerServiceImp: TimerService {

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.repeatingInterval,
                   repeating: self.repeatingInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    private let repeatingInterval: DispatchTimeInterval

    private var eventHandler: (() -> Void)?

    // MARK: - Object Lifecycle

    /// Initializes an TimerServiceImp with given timer and repeating interval
    ///
    /// - Parameters:
    ///     - repeatingInterval: A time interval of  seconds, millisconds, microseconds, or nanoseconds. Default is never
    init(repeatingInterval: DispatchTimeInterval = .never) {
        self.repeatingInterval = repeatingInterval
    }

    deinit {
        timer.setEventHandler { }
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        timer.resume()
    }

    // MARK: - TimerService

    /// This method will update the event handler and will start the timer if it is not running state already
    ///
    /// - parameter eventHandler:   Handler that should be executed when timer fires
    func start(_ eventHandler: @escaping TimerEventHandler) {
        self.eventHandler = eventHandler
        resume()
    }

    /// This method will stop the timer if it is not in suspended state already
    func stop() {
        suspend()
    }

    // MARK: - State

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    private func resume() {
        if state == .resumed {
            // already running
            return
        }
        state = .resumed
        timer.resume()
    }

    private func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }

}
