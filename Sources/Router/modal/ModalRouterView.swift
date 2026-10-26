import SwiftUI

/// Attach at a stable presentation scope. Popovers anchor to this host's base content.
/// The app chooses whether the destination embeds a StackRouterView.
@MainActor
public struct ModalRouterView<Route: Hashable, Base: View, Destination: View>: View {
    private let router: ModalRouter<Route>
    private let content: () -> Base
    private let destination: (PresentedRoute<Route>) -> Destination

    public init(
        _ router: ModalRouter<Route>,
        @ViewBuilder content: @escaping () -> Base,
        @ViewBuilder destination: @escaping (PresentedRoute<Route>) -> Destination
    ) {
        self.router = router
        self.content = content
        self.destination = destination
    }

    public var body: some View {
        content()
            .sheet(item: router.presentationBinding(for: .sheet)) { item in
                destination(item)
                    .interactiveDismissDisabled(!item.canDismiss)
            }
            .popover(item: router.presentationBinding(for: .popover)) { item in
                destination(item)
                    .interactiveDismissDisabled(!item.canDismiss)
            }
    }
}

extension ModalRouter {
    func presentationBinding(for style: PresentationStyle) -> Binding<PresentedRoute<Route>?> {
        // A SwiftUI dismissal can arrive after a new presentation was admitted.
        // Capture the rendered identity rather than dismissing whatever is current then.
        let renderedID = presentation?.style == style ? presentation?.id : nil
        return Binding(
            get: {
                guard let item = self.presentation, item.style == style else { return nil }
                return item
            },
            set: { value in
                guard value == nil, let renderedID else { return }
                self.dismiss(id: renderedID)
            }
        )
    }
}
