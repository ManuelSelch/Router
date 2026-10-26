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
    @State private var modal = ModalRouter<DemoRoute>()

    public init() {}

    public var body: some View {
        ModalRouterView(modal) {
            StackRouterView(stack) { route in
                DemoScreen(
                    title: String(describing: route),
                    onPush: { stack.push(.detail) },
                    onPop: { stack.pop() },
                    onSettings: { modal.present(.settings) },
                    onPopover: { modal.present(.detail, style: .popover) }
                )
            }
        } destination: { flow in
            DemoPresentedFlow(flow: flow, onDismiss: { modal.dismiss(id: flow.id) })
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
    @Bindable var flow: PresentedRoute<DemoRoute>
    let onDismiss: () -> Void

    var body: some View {
        StackRouterView(flow.stack) { route in
            VStack(spacing: 16) {
                Text(String(describing: route)).font(.headline)
                Toggle("Allow dismissal", isOn: $flow.canDismiss)
                Button("Push detail") { flow.stack.push(.detail) }
                Button("Pop") { flow.stack.pop() }
                Button("Done", action: onDismiss).disabled(!flow.canDismiss)
            }
            .padding()
        }
        .frame(minWidth: 260, minHeight: 240)
    }
}
