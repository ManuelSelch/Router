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
    
    public var currentRoute: Route? {
        if let popup = popup {
            return popup
        }
        if let sheet = sheet {
            return sheet.currentRoute
        }
        if let root = root {
            return root.currentRoute
        } else {
            return routers[tab]?.currentRoute
        }
    }
    
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
    
    public func push(_ route: Route) {
        if var sheet = sheet {
            sheet.push(route)
        } else if routers[tab] != nil {
            routers[tab]?.push(route)
        } else {
            root?.push(route)
        }
    }
    
    public func showSheet(_ route: Route) {
        sheet = StackRouter(root: route)
    }
    
    public func showTab(_ tab: TabRoute, route: Route) {
        self.root = nil
        routers[tab]? = .init(root: route)
    }
    
    public func showRoot(_ route: Route) {
        self.root = .init(root: route)
    }
    
    public func showPopup(_ route: Route) {
        self.popup = popup;
    }
    
    public func dismiss() {
        if popup != nil {
            popup = nil
        }
        else if sheet != nil {
            sheet = nil
        }
        else if root != nil {
            root?.dismiss()
        }
        else {
            routers[tab]?.dismiss()
        }
    }
}
