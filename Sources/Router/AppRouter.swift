import Foundation
import Redux

public class AppRouter<
    Route: Equatable & Hashable & Identifiable & Codable,
    TabRoute: Equatable & Hashable & Codable & Identifiable & CaseIterable
>: ObservableObject {
    
    
    @Published var root: StackRouter<Route>?
    @Published var tab: TabRoute
    @Published var routers: [TabRoute:StackRouter<Route>]
    
    @Published var sheet: StackRouter<Route>?
    @Published var popup: Route?
    
    public init(
        root: Route? = nil,
        tab: TabRoute,
        routers: [TabRoute : StackRouter<Route>]
    ) {
        if let root = root {
            self.root = .init(root: root)
        }
        self.tab = tab
        self.routers = routers
        self.sheet = nil
        self.popup = nil
    }
    
    public func push(route: Route) {
        if var sheet = sheet {
            sheet.push(route)
        } else if routers[tab] != nil {
            routers[tab]?.push(route)
        } else {
            root?.push(route)
        }
    }
    
    public func presentSheet(_ route: Route) {
        sheet = StackRouter(root: route)
    }
    
    public func showTab(tab: TabRoute, route: Route) {
        self.root = nil
        routers[tab]? = .init(root: route)
    }
    
    public func showRoot(route: Route) {
        self.root = .init(root: route)
    }
}
