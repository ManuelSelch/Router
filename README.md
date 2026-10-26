# Router

Small, dependency-free, state-driven SwiftUI navigation for **iOS 17+**, **macOS 14+**,
and **Mac Catalyst 17+**. Built with Swift 6, Observation and native platform presentations.
This is a breaking modernization of 1.0.10, not a drop-in update.

## Install

Add this repository through Swift Package Manager and link the **Router** product.
The separately buildable **RouterDemo** product contains example views; it is not a dependency
of Router. No external packages are required.

## Stack navigation

Routes only need `Hashable`; neither `Codable` nor `Identifiable` is required.

```swift
import Router
import SwiftUI

enum Route: Hashable {
    case home
    case detail(Int)
    case settings
}

@MainActor
struct RootView: View {
    @State private var stack = StackRouter(root: Route.home)

    var body: some View {
        StackRouterView(stack) { route in
            switch route {
            case .home:
                Button("Open detail") { stack.push(.detail(1)) }
            case .detail(let id):
                VStack {
                    Text("Detail \(id)")
                    Button("Back") { stack.pop() }
                }
            case .settings:
                Text("Settings")
            }
        }
    }
}
```

- `push` appends a route; `pop` returns the removed route or nil at the root.
- `popToRoot` clears the path without removing the root.
- `replaceRoot` replaces the root and clears its path.
- `setPath` replaces the typed path, for example for app-owned deep linking.
- Native Back navigation updates the same path.
- Models are main-actor isolated. Own them in `@State` or inject an instance per scene/flow;
  do not share a global singleton across unrelated windows.

## App-level sheets and popovers

Wrap the app's workspace at its composition boundary, rather than constructing Settings
inside Workspace. The app owns the destination mapping:

```swift
@MainActor
struct AppRoot: View {
    @State private var presentations = PresentationRouter<Route>()

    var body: some View {
        PresentationRouterView(presentations) {
            Button("Settings") { presentations.present(.settings) }
        } destination: { item in
            StackRouterView(item.stack) { route in
                VStack {
                    Text(String(describing: route))
                    Button("Done") { presentations.dismiss(id: item.id) }
                }
                .padding()
            }
        }
    }
}
```

- `present(route)` uses a native sheet. Pass `style: .popover` for a native popover.
- Admission returns false if this scope is occupied. Dismiss the existing flow explicitly;
  a new request never silently replaces it.
- Every presentation has a stable UUID and its own stack. Pushing, popping or replacing
  that stack's root does not change the presentation identity.
- `dismiss()` closes the current presentation. Use `dismiss(id:)` in delayed callbacks
  so an obsolete callback cannot dismiss a newer flow.
- Set `item.canDismiss = false` while saving. Hosts disable interactive dismissal;
  router commands and native dismissal binding writes also respect this guard.
  Re-enable it before dismissing. Use router dismissal for guarded app actions rather
  than bypassing the router with SwiftUI's environment dismiss action.
- Destination content may embed `StackRouterView` or render directly.
- Popovers anchor to the host's base content and may adapt to a sheet on compact iOS.
  Attach a host to the relevant control when a specific anchor is needed. System styling,
  transitions and focus behavior are intentional; this is not a custom overlay framework.
- Nested independent presentation scopes can be composed explicitly. This library does
  not automatically choose an active stack or walk a global presentation tree.
- Programmatic dismissal mutates routing state immediately; native transition animations
  remain asynchronous. It does not provide a presentation-completion queue.

## Optional native tabs

```swift
enum Tab: Hashable { case chats, projects }

@MainActor
func makeTabs() throws -> TabRouter<Tab, Route> {
    try TabRouter(
        tabs: [
            (.chats, StackRouter(root: .home)),
            (.projects, StackRouter(root: .detail(1)))
        ],
        selected: .chats
    )
}

// In a View, keep the configured router in @State or an injected scope:
// TabRouterView(tabs) { route in
//     Text(String(describing: route))
// } label: { tab in
//     Text(String(describing: tab))
// }
```

Tab configuration is ordered and fixed for each router instance. Empty configuration, duplicate
tabs and an unknown initial selection throw `TabRouterConfigurationError`. Selecting an unknown
tab returns false and leaves selection unchanged. Selecting a configured tab preserves its
stack. Neither `CaseIterable` nor `Identifiable` is required.

Use app-owned workspace state for dynamic document/session tabs; `TabRouterView` is a native
tab shell, not a document manager.

## Breaking changes from 1.0.10

| Previous API | Modern equivalent |
|---|---|
| `AppRouter` | Compose `StackRouter`, `PresentationRouter` and optional `TabRouter` |
| `StackWithSheetRouter` | Stack plus an independently scoped `PresentationRouter` |
| `AppRouterView`, `StackWithSheetRouterView` | `PresentationRouterView` around the relevant base view |
| `stack`, `updateRoutes` | Read `path`; mutate via `setPath` |
| `presentRoot`, `goBackToRoot` | `replaceRoot`, `popToRoot` |
| Ambiguous `dismiss` | Stack `pop` versus presentation `dismiss` |
| `showTab` | `TabRouter.select`; explicit stack replacement when wanted |
| `showSheet`, `presentSheet` | `PresentationRouter.present` |
| `showPopup`, `presentPopup` | Native `present(..., style: .popover)` |
| `ObservableObject`, `@StateObject` | `@Observable`, `@State`; `@Bindable` where needed |
| Mutable root-derived identity | Separate stable presentation UUID |
| Mandatory Codable/Identifiable routes | Hashable routes |

There are no legacy aliases or compatibility fallbacks. Codable restoration, custom animations,
full-screen covers, arbitrary overlays and a deep-link engine are outside this library's scope.

## Examples and verification

`Sources/Demo/RouterDemo.swift` contains public `RouterDemoView` (stack and presentations)
and `TabbedRouterDemoView` (throwing configuration initializer). Both are library views:
embed them in your own app or preview; this package does not provide an executable app.

```sh
swift test
swift build -c release
swift build --target RouterDemo
```

Model tests cover navigation, Observation, identity, guarded/stale dismissal and tab validation.
Host-boundary tests use the exact binding adapters wired into the SwiftUI hosts. They do **not**
constitute end-to-end evidence for native gestures, focus, accessibility or animation timing.
See [implementation evidence](docs/native-modernization/IMPLEMENTATION.md) for platform checks
and remaining manual acceptance.

## License

MIT, as stated by the original project.
