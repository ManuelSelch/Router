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
            .sheet(item: router.presentationBinding(for: .sheet)) { flow in
                destination(flow)
                    .interactiveDismissDisabled(!flow.canDismiss)
            }
            .popover(item: router.presentationBinding(for: .popover)) { flow in
                destination(flow)
                    .interactiveDismissDisabled(!flow.canDismiss)
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
                guard let flow = self.presentation, flow.style == style else { return nil }
                return flow
            },
            set: { value in
                guard value == nil, let renderedID else { return }
                self.dismiss(id: renderedID)
            }
        )
    }
}
