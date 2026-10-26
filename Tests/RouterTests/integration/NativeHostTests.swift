import Testing
@testable import Router

@Suite @MainActor
struct NativeHostTests {
    @Test func nativeBackWritesToTheAuthoritativeStack() {
        let app = NativeHostDriver()
        app.push(.detail(1))
        app.push(.detail(2))
        app.nativeBack(to: [.detail(1)])
        app.expectPath([.detail(1)])
        app.nativeBack(to: [])
        app.expectPath([])
    }

    @Test func nativeSheetDismissalUsesTheGuardAndIdentity() throws {
        let app = NativeHostDriver()
        try app.present(.settings, style: .sheet)
        app.expectOnly(.sheet)
        app.blockDismissal()
        app.nativeDismiss()
        app.expectPresented(true)
        app.allowDismissal()
        app.nativeDismiss()
        app.expectPresented(false)
        try app.present(.settings, style: .sheet)
        app.oldNativeDismiss()
        app.expectPresented(true)
    }

    @Test func nativePopoverDismissalCannotClearANewerSheet() throws {
        let app = NativeHostDriver()
        try app.present(.detail(1), style: .popover)
        app.expectOnly(.popover)
        app.nativeDismiss()
        app.expectPresented(false)
        try app.present(.settings, style: .sheet)
        app.oldNativeDismiss()
        app.expectOnly(.sheet)
    }

    @Test func nativeTabSelectionPreservesStackAndRejectsUnknownTab() throws {
        let app = try NativeTabDriver()
        app.push(.detail(1))
        app.nativeSelect(.projects)
        app.expectSelected(.projects)
        app.nativeSelect(.missing)
        app.expectSelected(.projects)
        app.nativeSelect(.chats)
        app.expectCurrentRoute(.detail(1))
    }
}
