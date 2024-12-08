# SwiftUI Router Library
A lightweight and dynamic library for managing navigation in SwiftUI apps. 
This library allows you to handle route stacks, tab navigation, popups, and sheets, making navigation intuitive and flexible.

# Features
- Stack Navigation: Push and pop routes dynamically within a stack.
- Tab Router: Manage multiple stacks using a tab-based interface.
- Popups: Present simple route views as popups.
- Sheets with Navigation: Open sheets that include their own stack routers for nested navigation.

# Usage
## Basic Setup
Define your routes and tabs using enums:

```swift
enum MyRoute: Equatable & Hashable & Identifiable & Codable {
    case route1
    case route2
    
    var id: Self { self }
}

enum MyTabRoute: Equatable & Hashable & Codable & Identifiable & CaseIterable {
    case tab1
    case tab2
    
    var id: Self { self }
}
```

## Initialize the Router
Create your app's router with initial tabs and stacks:

```swift
@MainActor
struct MyRouter {
    static let shared: AppRouter<MyRoute, MyTabRoute> = AppRouter(
        tab: .tab1,
        routers: [
            .tab1: StackRouter(root: .route1),
            .tab2: StackRouter(root: .route2)
        ]
    )
}
```

## Build the View
Use AppRouterView to render your routes and tabs:

```swift
struct SwiftUIView: View {
    var body: some View {
        AppRouterView(
            router: MyRouter.router,
            header: {
                Text("Header")
            },
            content: { route in
                VStack {
                    switch route {
                    case .route1:
                        Text("Route 1")
                        Button("Go to Route 2", action: { MyRouter.shared.push(route: .route2) })
                    case .route2:
                        Text("Route 2")
                        Button("Go to Route 1", action: { MyRouter.shared.push(route: .route1) })
                    }
                }
            },
            label: { tab in
                Text("\(tab)")
            }
        )
    }
}
```

## Handle Sheets and Popups
- Popups: Display simple, temporary views.
- Sheets: Open modals with their own stack navigation.

```swift
MyRouter.shared.presentSheet(route: .route1)
```

# Installation
Add the package to your XCode project. 
Ensure your SwiftUI app uses the @StateObject or dependency injection to manage the router.

# License
This library is provided under the MIT License. Feel free to use it in your projects!
