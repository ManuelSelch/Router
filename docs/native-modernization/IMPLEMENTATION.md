# Native modernization — Implementation evidence

All three approved slices are implemented on `feat/native-modernization`.
This is a breaking library update; Pi Studio integration and publication are not included.
The original unversioned Router folder was not modified.

## Delivered

- **S1:** main-actor Observation models for independent stacks, scoped presentation,
  and ordered fixed tabs. Routes require only Hashable. Presentations own stable UUIDs.
  Pop and presentation dismissal are distinct; guard and identity checks protect dismissal.
- **S2:** native SwiftUI NavigationStack, sheet, popover and TabView hosts. Native path,
  selection and dismissal adapters write to authoritative model state. Presentation adapters
  capture rendered identity so obsolete dismissals cannot clear a newer presentation.
- **S3:** no external dependencies or stale dependency lockfile; Router exports only its core.
  RouterDemo is a separate library product, with stack/presentation and optional tab examples.
  README documents construction, behavior, scope and breaking API replacements.

## Verification performed

Environment: Xcode 26.1.1 (17B100), Swift 6.2.1, macOS host.
Build/test outputs were placed under
`~/Library/Developer/Xcode/DerivedData/RouterModernized`, outside the Documents checkout.

| Check | Result |
|---|---|
| SwiftPM Debug tests, warnings as errors | 16 tests / 4 suites pass |
| SwiftPM Release tests, warnings as errors | 16 tests / 4 suites pass |
| SwiftPM Release build, core and demo | Pass |
| Native macOS Release, RouterDemo plus core | arm64 + x86_64 pass; deployment target macOS 14 |
| iOS Simulator Release, RouterDemo plus core | arm64 + x86_64 pass; deployment target iOS 17 |
| Mac Catalyst Release, RouterDemo plus core | arm64 + x86_64 pass; deployment target Catalyst 17 |
| Package manifest inspection | No external dependencies; core product contains Router only |
| Git whitespace check | Pass |

Tests were added before their corresponding model/host implementations. Missing new
APIs produced the initial red compilation runs; the final implementation passes the suites.
Coverage includes root/path operations and observation, nested observation, presentation
admission and stable identity, dismissal guards, stale callbacks, invalid tab configuration,
selection and stack preservation. Integration scenarios use semantic test drivers and the
same binding adapters the production SwiftUI hosts consume.

Representative reproduction commands, from the repository root:

```sh
BUILD_ROOT="$HOME/Library/Developer/Xcode/DerivedData/RouterModernized"
swift test --scratch-path "$BUILD_ROOT/spm" -Xswiftc -warnings-as-errors
swift test -c release --scratch-path "$BUILD_ROOT/spm" -Xswiftc -warnings-as-errors
swift build -c release --scratch-path "$BUILD_ROOT/spm" -Xswiftc -warnings-as-errors
xcodebuild -scheme RouterDemo -configuration Release \
  -destination 'generic/platform=macOS' -derivedDataPath "$BUILD_ROOT/macos" \
  CODE_SIGNING_ALLOWED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcodebuild -scheme RouterDemo -configuration Release \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$BUILD_ROOT/ios" \
  CODE_SIGNING_ALLOWED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcodebuild -scheme RouterDemo -configuration Release \
  -destination 'generic/platform=macOS,variant=Mac Catalyst' \
  -derivedDataPath "$BUILD_ROOT/catalyst" \
  CODE_SIGNING_ALLOWED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

## Acceptance limits

- No desktop-controlling macOS automation, visible app launch, Simulator app interaction
  or physical-device testing was performed.
- Host-boundary tests instantiate hosts and exercise their actual binding adapters.
  They do not prove native Back gestures, sheet swipes, outside-click popover dismissal,
  focus/keyboard restoration, accessibility, or animation timing.
- Manually verify both allowed and blocked native dismissal, re-enable and dismiss,
  nested sheet Back versus closing the sheet, compact-iOS popover adaptation,
  tab stack preservation, focus restoration and VoiceOver behavior.
- Minimum deployment versions were compilation targets, not OS versions used for runtime tests.
- Programmatic routing state updates immediately; there is no asynchronous presentation queue.
- No release tag, push or downstream consumer migration is part of this task.
