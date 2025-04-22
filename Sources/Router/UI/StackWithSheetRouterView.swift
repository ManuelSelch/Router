import SwiftUI
import SwiftEntryKit

public struct StackWithSheetRouterView<
    Route: Equatable & Hashable & Identifiable & Codable,
    Content: View
>: View {
    @ObservedObject var router: StackWithSheetRouter<Route>
    let content: (Route) -> Content
    
    public init(_ router: StackWithSheetRouter<Route>, content: @escaping (Route) -> Content) {
        self.router = router
        self.content = content
    }
    
    public var body: some View {
        StackRouterView(router.stack, content: content)
            .sheet(item: $router.sheet) { sheet in
                StackRouterView(sheet, content: content)
            }
            .onChange(of: router.popup) { _ in
                if let popup = router.popup {
                    PopupManager.present(route: popup, onClose: {router.popup = nil}, content: content)
                }
            }
    }
}
