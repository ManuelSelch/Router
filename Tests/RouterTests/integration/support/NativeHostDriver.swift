import SwiftUI
import Testing
@testable import Router

/// Exercises the actual adapters consumed by native hosts, not simulated routing logic.
@MainActor
final class NativeHostDriver {
    private let stack = StackRouter(root: Screen.home)
    private let modal = ModalRouter<Screen>()
    private var current: Binding<PresentedRoute<Screen>?>?
    private var previous: Binding<PresentedRoute<Screen>?>?

    func push(_ screen: Screen) { stack.push(screen) }
    func nativeBack(to path: [Screen]) { stack.pathBinding.wrappedValue = path }
    func expectPath(_ path: [Screen], sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(stack.path == path, sourceLocation: sourceLocation)
    }

    func present(_ screen: Screen, style: PresentationStyle) throws {
        previous = current
        #expect(modal.present(screen, style: style))
        current = modal.presentationBinding(for: style)
        _ = try #require(current?.wrappedValue)
        // Instantiate both host entry points using the same models.
        _ = StackRouterView(stack) { Text(String(describing: $0)) }
        _ = ModalRouterView(modal) { Text("Root") } destination: { flow in
            StackRouterView(flow.stack) { Text(String(describing: $0)) }
        }
    }
    func blockDismissal() { modal.presentation?.canDismiss = false }
    func allowDismissal() { modal.presentation?.canDismiss = true }
    func nativeDismiss() { current?.wrappedValue = nil }
    func oldNativeDismiss() { previous?.wrappedValue = nil }

    func expectPresented(_ value: Bool, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect((modal.presentation != nil) == value, sourceLocation: sourceLocation)
    }
    func expectOnly(_ style: PresentationStyle, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(modal.presentationBinding(for: style).wrappedValue != nil,
                sourceLocation: sourceLocation)
        let other: PresentationStyle = style == .sheet ? .popover : .sheet
        #expect(modal.presentationBinding(for: other).wrappedValue == nil,
                sourceLocation: sourceLocation)
    }
}

@MainActor
final class NativeTabDriver {
    private let router: TabRouter<AppTab, Screen>
    init() throws {
        router = try TabRouter(tabs: [
            (.chats, StackRouter(root: .home)),
            (.projects, StackRouter(root: .settings))
        ], selected: .chats)
        _ = TabRouterView(router) { Text(String(describing: $0)) } label: { tab in
            Text(String(describing: tab))
        }
    }
    func push(_ screen: Screen) { router.selectedStack.push(screen) }
    func nativeSelect(_ tab: AppTab) { router.selectionBinding.wrappedValue = tab }
    func expectSelected(_ tab: AppTab, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(router.selected == tab, sourceLocation: sourceLocation)
    }
    func expectCurrentRoute(_ screen: Screen, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(router.selectedStack.currentRoute == screen, sourceLocation: sourceLocation)
    }
}
