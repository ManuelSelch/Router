import Foundation

public class StackWithSheetRouter<Route: Equatable & Hashable & Identifiable & Codable>: ObservableObject {
    @Published public var stack: StackRouter<Route>
    @Published public var sheet: StackRouter<Route>?
    @Published var popup: Route?
    
    public init(root: Route) {
        self.stack = .init(root: root)
        self.sheet = nil
        self.popup = nil
    }
    
    public func presentSheet(_ root: Route) {
        self.sheet = .init(root: root)
    }
    
    public func presentPopup(_ route: Route) {
        self.popup = route
    }
}
