import Foundation

/// Observation invokes onChange synchronously; protect the flag for its Sendable callback.
final class ChangeFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false
    var changed: Bool { lock.withLock { value } }
    func mark() { lock.withLock { value = true } }
}
