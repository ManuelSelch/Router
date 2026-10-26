import SwiftUI

/// A native tab shell for a configured, ordered set of independent navigation stacks.
@MainActor
public struct TabRouterView<Tab: Hashable, Route: Hashable, Content: View, Label: View>: View {
    private let router: TabRouter<Tab, Route>
    private let content: (Route) -> Content
    private let label: (Tab) -> Label

    public init(
        _ router: TabRouter<Tab, Route>,
        @ViewBuilder content: @escaping (Route) -> Content,
        @ViewBuilder label: @escaping (Tab) -> Label
    ) {
        self.router = router
        self.content = content
        self.label = label
    }

    public var body: some View {
        TabView(selection: router.selectionBinding) {
            ForEach(router.tabs, id: \.self) { tab in
                if let stack = router.stack(for: tab) {
                    StackRouterView(stack, content: content)
                        .tabItem { label(tab) }
                        .tag(tab)
                }
            }
        }
    }
}

extension TabRouter {
    var selectionBinding: Binding<Tab> {
        Binding(get: { self.selected }, set: { self.select($0) })
    }
}
