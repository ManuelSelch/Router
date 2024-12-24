import SwiftUI
import PopupView

public struct AppRouterView<
    Route: Equatable & Hashable & Identifiable & Codable,
    TabRoute: Equatable & Hashable & Codable & Identifiable & CaseIterable,
    Header: View,
    Content: View,
    Label: View
>: View where TabRoute.AllCases: RandomAccessCollection {
    @ObservedObject var router: AppRouter<Route, TabRoute>
    
    let header: () -> Header
    let content: (Route) -> Content
    let label: (TabRoute) -> Label
    
  
    public init(
        router: AppRouter<Route, TabRoute>,
        header: @escaping () -> Header,
        content: @escaping (Route) -> Content,
        label: @escaping (TabRoute) -> Label
    )
    {
        self.router = router
        self.header = header
        self.content = content
        self.label = label
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            header()
            
            if let root = router.root {
                StackRouterView(
                    root: root.root,
                    stack:  Binding(
                        get: { router.root?.stack ?? []},
                        set: { router.root?.stack = $0 }
                    ),
                    content: { route in
                        content(route)
                    }
                )
            } else {
                TabRouterView(
                    tab: $router.tab,
                    content: { tab in
                        StackRouterView(
                            root: router.routers[tab]!.root,
                            stack: Binding(
                                get: { router.routers[tab]?.stack ?? []},
                                set: { router.routers[tab]?.stack = $0 }
                            ),
                            content: { route in
                                content(route)
                            }
                        )
                    },
                    label: { route in
                        label(route)
                    }
                )
            }
            
        
            
            
           
        }
        
        .sheet(
            item: $router.sheet
        )
        { sheet in
            
            StackRouterView(
                root: sheet.root,
                stack: Binding(
                    get: { router.sheet?.stack ?? [] },
                    set: { router.sheet?.stack = $0 }
                )
            ) { route in
                content(route)
            }
             
        }
        
        .popup(
            item: $router.popup,
            itemView: { route in
                content(route)
            },
            customize: {
                $0
                    .backgroundColor(Color.black.opacity(0.8))
                    .closeOnTap(false)
                    .closeOnTapOutside(true)
            }
            
        )
         
    }
}

