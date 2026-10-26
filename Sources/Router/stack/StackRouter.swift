import Observation

/// A typed navigation stack. Own one instance per independent flow.
@MainActor @Observable
public final class StackRouter<Route: Hashable> {
    public private(set) var root: Route
    public private(set) var path: [Route]

    public init(root: Route, path: [Route] = []) {
        self.root = root
        self.path = path
    }

    public var currentRoute: Route { path.last ?? root }

    public func push(_ route: Route) { path.append(route) }

    @discardableResult
    public func pop() -> Route? { path.popLast() }

    public func popToRoot() { path = [] }

    public func replaceRoot(_ route: Route) {
        root = route
        path = []
    }

    /// Replaces the path, including writes from SwiftUI's native Back navigation.
    public func setPath(_ path: [Route]) { self.path = path }
}
