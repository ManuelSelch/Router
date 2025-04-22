import SwiftUI
import NavigationTransitions

public struct StackRouterView<
    Route: Equatable & Hashable & Identifiable & Codable,
    Content: View
>: View {
    @ObservedObject var router: StackRouter<Route>
    let content: (Route) -> Content
    
    public init(_ router: StackRouter<Route>, content: @escaping (Route) -> Content) {
        self.router = router
        self.content = content
    }
    
    public var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(path: $router.stack) {
                content(router.root)
                    .navigationDestination(for: Route.self) { route in
                        content(route)
                    }
            }
            .navigationTransition(.slide)
        } else {
            NavigationView {
                ZStack {
                    content(router.stack.last ?? router.root)
                        .transition(.slide)
                }
                .animation(.easeInOut, value: router.stack)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        }
        
    }
}
