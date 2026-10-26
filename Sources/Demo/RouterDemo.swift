import Router
import SwiftUI

private enum DemoRoute: Hashable {
    case home
    case detail
    case settings
}

private enum DemoTab: Hashable {
    case chats
    case projects
}

/// Stack and app-level settings composition without any tab requirement.
@MainActor
public struct RouterDemoView: View {
    @State private var stack = StackRouter(root: DemoRoute.home)
    @State private var presentations = ModalRouter<DemoRoute>()

    public init() {}

    public var body: some View {
        ModalRouterView(presentations) {
            StackRouterView(stack) { route in
                DemoScreen(
                    title: String(describing: route),
                    onPush: { stack.push(.detail) },
                    onPop: { stack.pop() },
                    onSettings: { presentations.present(.settings) },
                    onPopover: { presentations.present(.detail, style: .popover) }
                )
            }
        } destination: { item in
            DemoPresentedFlow(item: item, onDismiss: { presentations.dismiss(id: item.id) })
        }
    }
}

/// Optional native tab composition; configuration errors are explicit at construction.
@MainActor
public struct TabbedRouterDemoView: View {
    @State private var tabs: TabRouter<DemoTab, DemoRoute>

    public init() throws {
        _tabs = State(initialValue: try TabRouter(
            tabs: [
                (.chats, StackRouter(root: .home)),
                (.projects, StackRouter(root: .detail))
            ],
            selected: .chats
        ))
    }

    public var body: some View {
        TabRouterView(tabs) { route in
            VStack {
                Text(String(describing: route))
                Button("Push detail") { tabs.selectedStack.push(.detail) }
                Button("Pop") { tabs.selectedStack.pop() }
            }
            .padding()
        } label: { tab in
            Label(tab == .chats ? "Chats" : "Projects",
                  systemImage: tab == .chats ? "bubble.left" : "folder")
        }
    }
}

private struct DemoScreen: View {
    let title: String
    let onPush: () -> Void
    let onPop: () -> Void
    let onSettings: () -> Void
    let onPopover: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title).font(.headline)
            Button("Push detail", action: onPush)
            Button("Pop", action: onPop)
            Button("Settings sheet", action: onSettings)
            Button("Detail popover", action: onPopover)
        }
        .padding()
    }
}

@MainActor
private struct DemoPresentedFlow: View {
    @Bindable var item: PresentedRoute<DemoRoute>
    let onDismiss: () -> Void

    var body: some View {
        StackRouterView(item.stack) { route in
            VStack(spacing: 16) {
                Text(String(describing: route)).font(.headline)
                Toggle("Allow dismissal", isOn: $item.canDismiss)
                Button("Push detail") { item.stack.push(.detail) }
                Button("Pop") { item.stack.pop() }
                Button("Done", action: onDismiss).disabled(!item.canDismiss)
            }
            .padding()
        }
        .frame(minWidth: 260, minHeight: 240)
    }
}
