import Foundation

#if !os(macOS)

/// A stub for compilation.
class NSDistributedLock {
    
    init?(path: String) { return nil }
    
    func `try`() -> Bool { return false }

    func unlock() { }

    var lockDate: Date { Date() }

}

#endif

public struct DistributedLock {
    
    /// Releases all distributed locks by deleting the files that they are
    /// associated with.
    public static func releaseAllLocks() {
        
        if Self.allLocks.isEmpty {
            return
        }
        
        print("RELEASING ALL LOCKS")
        
        for lock in Self.allLocks {
            
            guard let path = lock.path else {
                continue
            }
            
            do {
                if FileManager.default.fileExists(atPath: path) {
                    try FileManager.default.removeItem(atPath: path)
                }
                Self.allLocks.removeAll(where: { $0.name == lock.name })

            } catch {
                print(
                    """

                    --------------------------------------------------
                    COULDN'T REMOVE LOCK AT PATH \(path):
                    \(error)
                    --------------------------------------------------

                    """
                )
            }
            
        }
        
    }
    
    private static var allLocks: [Self] = []
    
    private static let lockDirectory: String? = {
        return ProcessInfo.processInfo.environment["SPOTIFY_LOCK_DIRECTORY"]
    }()

    // MARK: - Locks -
    
    public static let general = Self(name: "general")
    public static let player = Self(name: "player")
    public static let library = Self(name: "library")
    public static let follow = Self(name: "follow")
    public static let rateLimitedError = Self(name: "rateLimitedError")
    public static let redirectListener = Self(name: "redirectListener")

    // MARK: - Instance Members -

    /// The name of this lock, which is displayed in the console for debugging
    /// purposes.
    public let name: String
    
    /// The path to the file that is used for this lock.
    public let path: String?

    let _lock: NSDistributedLock?
    
    let queue: DispatchQueue

    private init(name: String) {

        self.name = name
        self.queue = DispatchQueue(label: "DistributedLock.\(name)")
        
        if let lockDirectory = Self.lockDirectory {
            let path = "\(lockDirectory)/\(name)"
            self.path = path
            self._lock = NSDistributedLock(path: path)
            Self.allLocks.append(self)
        }
        else {
            self.path = nil
            self._lock = nil
        }

    }
    
    // MARK: - Locking

    /// Polls the lock at an interval of 0.25 seconds until it is acquired.
    public func lock() {
        self.queue.sync {
            guard let lock = self._lock else {
                return
            }
            print(
                "waiting for \(self.name) distributed lock; " +
                "lockDate: \(lock.lockDate.description(with: .current))"
            )
            while !lock.try() {
                usleep(250_000)  // 0.25 seconds
            }
            print("acquired \(self.name) distributed lock")
        }
    }
    
    /// Unlocks the lock.
    public func unlock() {
        self.queue.sync {
            if let lock = self._lock {
                print("released \(self.name) distributed lock")
                lock.unlock()
            }
        }
    }

    public func withLock<T>(_ block: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try block()
    }

}
