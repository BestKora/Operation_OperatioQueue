import Foundation

fileprivate var lastStartTime = Date()

public func startClock(){
    lastStartTime = Date()
}

public func stopClock() -> TimeInterval {
    return Date().timeIntervalSince(lastStartTime)
}


