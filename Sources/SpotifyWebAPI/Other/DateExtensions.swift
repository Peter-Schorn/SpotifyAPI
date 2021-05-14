import Foundation

public extension Date {
    
    /// The interval, in milliseconds, between the date value and 00:00:00 UTC
    /// on 1 January 1970. Equivalent to `self.timeIntervalSince1970 * 1000`.
    var millisecondsSince1970: Double {
        return self.timeIntervalSince1970 * 1000
    }

    /**
     Creates a date value initialized relative to 00:00:00 UTC on 1 January 1970
     by a given number of **milliseconds**.
     
     equivalent to
     ```
     self.init(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
     ```
     - Parameter millisecondsSince1970: A time interval in milliseconds.
     */
    init(millisecondsSince1970: Double) {
        self.init(
            timeIntervalSince1970: TimeInterval(millisecondsSince1970) / 1000
        )
    }
    
}
