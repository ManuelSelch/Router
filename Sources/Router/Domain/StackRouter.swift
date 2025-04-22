import Foundation

public class StackRouter<Route: Equatable & Hashable & Identifiable & Codable>: Equatable, Identifiable, ObservableObject
{
    public var id: Route {
        get { self.root }
    }
    
    public var root: Route
    @Published public var stack: [Route] = []
    
    
    public init(root: Route){
        self.root = root
    }
    
    public var currentRoute: Route {
        return stack.last ?? root
    }
    
    
    public func push(_ route: Route) {
        stack.append(route)
    }
    
    public func presentRoot(_ route: Route) {
        root = route
        stack = []
    }
    
    public func updateRoutes(_ routes: [Route]) {
        stack = routes
    }
    
    public func dismiss() {
        _ = stack.popLast()
    }
    
    public func goBackToRoot() {
        stack = []
    }
    
    public static func == (lhs: StackRouter<Route>, rhs: StackRouter<Route>) -> Bool {
        return lhs.root == rhs.root && lhs.stack == rhs.stack
    }
}


