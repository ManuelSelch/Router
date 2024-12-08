import SwiftUI
import Router

enum MyRoute: Equatable & Hashable & Identifiable & Codable {
    case route1
    case route2
    
    var id: Self {self}
}

enum MyTabRoute: Equatable & Hashable & Codable & Identifiable & CaseIterable {
    case tab1
    case tab2
    
    var id: Self {self}
}


@MainActor
class MyRouter: ObservableObject {
    static let shared: AppRouter<MyRoute, MyTabRoute> = AppRouter(
        tab: .tab1,
        routers: [
            .tab1: StackRouter(root: .route1),
            .tab2: StackRouter(root: .route2)
        ]
    )
}


struct SwiftUIView: View {
    @StateObject var router = MyRouter.shared
    
    var body: some View {
        AppRouterView(
            router: router,
            header: {
                Text("Header")
            }, content: { route in
                VStack {
                    switch(route) {
                    case .route1:
                        Text("Route 1")
                        Button("Route 2", action: { router.push(route: .route2)} )
                    case .route2:
                        Text("Route 2")
                        Button("Route 1", action: { router.push(route: .route1)} )
                    }
                }
            }, label: { tab in
                Text("\(tab)")
            }
        )
    }
}

#Preview {
    SwiftUIView()
}
