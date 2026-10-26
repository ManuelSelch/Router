import SwiftUI

/// Resolves typed routes using app-owned views and native platform navigation.
@MainActor
public struct StackRouterView<Route: Hashable, Content: View>: View {
    private let router: StackRouter<Route>
    private let content: (Route) -> Content

    public init(_ router: StackRouter<Route>, @ViewBuilder content: @escaping (Route) -> Content) {
        self.router = router
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: router.pathBinding) {
            content(router.root)
                .navigationDestination(for: Route.self, destination: content)
        }
    }
}

extension StackRouter {
    var pathBinding: Binding<[Route]> {
        Binding(get: { self.path }, set: { self.setPath($0) })
    }
}
