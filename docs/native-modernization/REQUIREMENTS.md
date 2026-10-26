# Router Native Modernization — Requirements

## Goal
Modernize the small typed SwiftUI router for native macOS and iOS without UIKit-dependent libraries. This work changes Router only; Pi Studio integration is separate.

## Requirements
- **R1** — Support iOS 17+, macOS 14+ and Mac Catalyst 17+ using Swift 6, Observation and main-actor-isolated navigation models.
- **R2** — Remove SwiftEntryKit and custom navigation transition dependencies; render stacks, sheets and popovers through native SwiftUI.
- **R3** — Separate stack navigation, modal presentation and optional tab selection. Stack-only and presentation-only use must not require tabs.
- **R4** — Require only Hashable route values; presentation instances have stable identities independent of mutable roots. Do not add persistence or require Codable.
- **R5** — Provide explicit push, pop, pop-to-root, root replacement, tab selection and presentation dismissal. Tab selection preserves stacks; missing tab configuration fails explicitly.
- **R6** — Native back and interactive dismissal update authoritative routing state. Blocked dismissal preserves that state. Replacing an active presentation requires explicit dismissal first.
- **R7** — Keep view construction app-owned and routers instance-scoped. No singleton, UIKit/AppKit adapter, custom overlay, full-screen cover or Pi Studio change is included.
- **R8** — Export only Router; keep a separately buildable example and document breaking API changes without legacy shims.
- **R9** — Add meaningful model and host-boundary regression tests; verify macOS tests/build and iOS Simulator compilation without desktop-controlling automation.

## Assumptions
- User approved the new minimum versions and breaking changes, with no legacy API shims.
- User authorized a fresh sibling clone; the existing unversioned Router directory remains untouched.

## Implementation Plan
### S1 — Observable Routing Models
Description: Deliver R1/R3–R5 with main-actor Observation models and red-first model tests for stack semantics, identity, tab preservation and explicit rejection.

### S2 — Native SwiftUI Hosts
Description: After S1, deliver R2/R6/R7 with native stack/presentation/tab hosts and dismissal-binding regression coverage. No custom popup rendering.

### S3 — Package, Examples and Verification
Description: Deliver R8/R9, remove dependency artifacts, update the example and README, run package tests and native platform compilation checks, then commit task changes without pushing.

## Open Questions
None.
