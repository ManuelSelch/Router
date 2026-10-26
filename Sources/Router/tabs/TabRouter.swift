import Observation

public enum TabRouterConfigurationError: Error, Equatable {
    case emptyTabs
    case duplicateTab
    case unknownSelection
}

/// An ordered, fixed set of independent stacks. Selection never resets a stack.
@MainActor @Observable
public final class TabRouter<Tab: Hashable, Route: Hashable> {
    public let tabs: [Tab]
    public private(set) var selected: Tab
    private let stacks: [Tab: StackRouter<Route>]

    public init(tabs: [(Tab, StackRouter<Route>)], selected: Tab) throws {
        guard !tabs.isEmpty else { throw TabRouterConfigurationError.emptyTabs }
        var stacks: [Tab: StackRouter<Route>] = [:]
        for (tab, stack) in tabs {
            guard stacks[tab] == nil else { throw TabRouterConfigurationError.duplicateTab }
            stacks[tab] = stack
        }
        guard stacks[selected] != nil else { throw TabRouterConfigurationError.unknownSelection }
        self.tabs = tabs.map(\.0)
        self.stacks = stacks
        self.selected = selected
    }

    // Initialization and select preserve membership in the immutable stacks dictionary.
    public var selectedStack: StackRouter<Route> { stacks[selected]! }

    public func stack(for tab: Tab) -> StackRouter<Route>? { stacks[tab] }

    @discardableResult
    public func select(_ tab: Tab) -> Bool {
        guard stacks[tab] != nil else { return false }
        selected = tab
        return true
    }
}
