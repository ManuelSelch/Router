import Observation
import Testing
@testable import Router

@Suite @MainActor
struct ModalRouterTests {
    @Test func admitsOnlyOnePresentationAcrossStyles() throws {
        let router = ModalRouter<Screen>()
        #expect(router.present(.settings, style: .sheet))
        let first = try #require(router.presentation)
        #expect(!router.present(.detail(1), style: .popover))
        #expect(router.presentation === first)
        #expect(first.style == .sheet)
        #expect(first.stack.root == .settings)
    }

    @Test func keepsIdentityWhileRootAndPathChange() throws {
        let router = ModalRouter<Screen>()
        router.present(.settings)
        let item = try #require(router.presentation)
        let id = item.id
        item.stack.push(.detail(1))
        item.stack.replaceRoot(.home)
        #expect(router.presentation?.id == id)
        #expect(router.presentation?.stack.currentRoute == .home)
        // Pop is not modal dismissal.
        item.stack.pop()
        #expect(router.presentation != nil)
    }

    @Test func blocksDismissalUntilAllowed() throws {
        let router = ModalRouter<Screen>()
        #expect(!router.dismiss())
        router.present(.settings)
        let item = try #require(router.presentation)
        item.canDismiss = false
        #expect(!router.dismiss())
        #expect(router.presentation === item)
        item.canDismiss = true
        #expect(router.dismiss())
        #expect(router.presentation == nil)
    }

    @Test func rejectsStaleDismissalAndGivesNewInstancesFreshIdentity() throws {
        let router = ModalRouter<Screen>()
        router.present(.settings)
        let oldID = try #require(router.presentation?.id)
        #expect(router.dismiss(id: oldID))
        router.present(.settings, style: .popover)
        let current = try #require(router.presentation)
        #expect(current.id != oldID)
        #expect(!router.dismiss(id: oldID))
        #expect(router.presentation === current)
        #expect(router.dismiss(id: current.id))
    }

    @Test func observationsTrackNestedStackAndDismissalGuard() throws {
        let router = ModalRouter<Screen>()
        router.present(.settings)
        let item = try #require(router.presentation)
        let flag = ChangeFlag()
        withObservationTracking {
            _ = router.presentation?.stack.currentRoute
            _ = router.presentation?.canDismiss
        } onChange: { flag.mark() }
        item.stack.push(.detail(1))
        #expect(flag.changed)
        let guardFlag = ChangeFlag()
        withObservationTracking { _ = item.canDismiss } onChange: { guardFlag.mark() }
        item.canDismiss = false
        #expect(guardFlag.changed)
    }
}
