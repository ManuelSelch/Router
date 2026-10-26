import Foundation
import Observation

public enum PresentationStyle: Sendable {
    case sheet
    case popover
}

/// Identity belongs to this presentation, not to its mutable root destination.
@MainActor @Observable
public final class PresentedRoute<Route: Hashable>: Identifiable {
    public nonisolated let id: UUID
    public let style: PresentationStyle
    public let stack: StackRouter<Route>
    public var canDismiss = true

    fileprivate init(root: Route, style: PresentationStyle) {
        self.id = UUID()
        self.style = style
        self.stack = StackRouter(root: root)
    }
}

/// Own one instance per presentation scope. Busy presentations are never replaced implicitly.
@MainActor @Observable
public final class PresentationRouter<Route: Hashable> {
    public private(set) var presentation: PresentedRoute<Route>?

    public init() {}

    /// Returns false if this scope already has a presentation.
    @discardableResult
    public func present(_ route: Route, style: PresentationStyle = .sheet) -> Bool {
        guard presentation == nil else { return false }
        presentation = PresentedRoute(root: route, style: style)
        return true
    }

    /// Dismisses the current presentation, respecting its guard.
    @discardableResult
    public func dismiss() -> Bool {
        guard let id = presentation?.id else { return false }
        return dismiss(id: id)
    }

    /// Prefer this overload for delayed callbacks to avoid dismissing a newer flow.
    @discardableResult
    public func dismiss(id: UUID) -> Bool {
        guard let item = presentation, item.id == id, item.canDismiss else { return false }
        presentation = nil
        return true
    }
}
