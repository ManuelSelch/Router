import SwiftUI
import SwiftEntryKit

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
                StackRouterView(root, content: content)
            } else {
                TabRouterView(
                    tab: $router.tab,
                    content: { tab in
                        VStack {
                            if let tabRouter = router.routers[tab] {
                                StackRouterView(tabRouter, content: content)
                            } else {
                                Text("Error: TabRouter not assigned")
                            }
                        }
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
            StackRouterView(sheet, content: content)
        }
        .onChange(of: router.popup) { _ in
            PopupManager.present(route: router.popup, onClose: {router.popup = nil}, content: content)
        }
    }
}

