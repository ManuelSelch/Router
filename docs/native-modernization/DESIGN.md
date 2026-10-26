# Router Native Modernization — Design

## Overview
Replace the UIKit-dependent implementation with small composable Observation models and native SwiftUI hosts. This is a breaking library-only change; Pi Studio and the existing unversioned checkout remain untouched.

## Components
| Package/module | Component | Change | Responsibility |
|---|---|---|---|
| Router | [StackRouter](../../Sources/Router/Domain/StackRouter.swift) | Changed | Main-actor root/path ownership and explicit stack commands. |
| Router | ModalRouter (proposed) | New | One optional identified sheet/popover flow; presentation admission and dismissal guards. Replaces popup globals and sheet fields scattered across routers. |
| Router | TabRouter (proposed) | New | Ordered configured tabs, selected tab and independent stacks; replaces tab behavior in AppRouter. |
| Router | Native host views (proposed) | Changed | Bind models to NavigationStack, sheet, popover and TabView; accept app-owned view builders. |
| RouterDemo | [Example](../../Sources/Demo/RouterDemo.swift) | Changed | Separately buildable example; app/scene-owned models, no singleton. |

Owners retain models in SwiftUI State or injected scopes. All models use MainActor and Observable. Stack-only usage does not instantiate presentation or tab state.

## Runtime flow
1. The app requests push/pop on a specific StackRouter. Its host binds NavigationStack to that router's path; native Back writes to the same path.
2. The app requests a sheet or popover from ModalRouter. If another presentation exists, admission returns false without replacement.
3. An admitted presentation receives a fresh UUID and its own StackRouter. Changing its root never changes the presentation UUID. Its content builder can render a StackRouterView when nested navigation is wanted.
4. Explicit dismissal or native dismissal clears that presentation. A dismissal guard prevents both interactive and programmatic dismissal while work is protected. Identity-checked callbacks from an older presentation cannot dismiss a newer one.
5. Tab selection validates configured membership and preserves every stack. Unknown tabs return failure without changing selection.

## Contracts & API changes
| Provider → consumer | Current → proposed contract | Compatibility |
|---|---|---|
| Router → apps | ObservableObject and broad route constraints → MainActor Observable models with Hashable routes | Breaking; iOS/Catalyst 17+, macOS 14+. |
| StackRouter → host | Mutable root-derived identity → observable root/path; presentation identity owned separately | Breaking; no implicit persistence. |
| AppRouter/StackWithSheetRouter → apps | Combined implicit routing → explicit StackRouter, ModalRouter and TabRouter composition | Breaking; no aliases or shims. |
| PopupManager → host | Global SwiftEntryKit popup → scoped native popover | Breaking visual semantics; no custom popup recreation. |
| Package → consumers | Router plus demo and two dependencies → Router-only product, separate example product, no external dependencies | Breaking packaging cleanup. |

## Decisions & Trade-offs
- Use SwiftUI only, with system animation and presentation behavior. macOS popovers and sheets may differ visually from iOS; platform adaptation is intentional.
- Native dismissal bindings and explicit commands share guarded state transitions. Hosts use presentation UUIDs to reject stale dismissal callbacks.
- Keep navigation imperative and small; no Flux, persistence, async navigation queue, deep-link engine or generic coordinator protocol is introduced.
- One presentation per ModalRouter; nested independent flows require explicit child composition. Apps choose appropriate scene/model lifetimes.

## Verification
- Red-first tests cover stack reset/pop, observation, stable presentation identity, duplicate admission, blocked dismissal, stale callbacks, tab validation and preserved stacks.
- Host-boundary tests exercise the same path/presentation binding adapters used by SwiftUI; builds alone do not prove real focus or interactive gesture behavior.
- Run SwiftPM tests and release build on macOS, and compile the library/example for an iOS Simulator. No desktop-controlling macOS UI automation; physical gestures/focus remain manual acceptance.
- These are planned checks, not results already obtained.

## Open Questions
None.
