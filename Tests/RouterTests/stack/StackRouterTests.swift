import Observation
import Testing
@testable import Router

// Deliberately neither Codable nor Identifiable.
enum Screen: Hashable { case home, detail(Int), settings }

@Suite @MainActor
struct StackRouterTests {
    @Test func pushesAndPopsWithoutRemovingRoot() {
        let router = StackRouter(root: Screen.home)
        router.push(.detail(1))
        router.push(.detail(2))
        #expect(router.currentRoute == .detail(2))
        #expect(router.pop() == .detail(2))
        #expect(router.pop() == .detail(1))
        #expect(router.pop() == nil)
        #expect(router.currentRoute == .home)
    }

    @Test func replacesRootAndClearsPath() {
        let router = StackRouter(root: Screen.home)
        router.push(.detail(1))
        router.replaceRoot(.settings)
        #expect(router.root == .settings)
        #expect(router.path.isEmpty)
        router.push(.detail(2))
        router.popToRoot()
        #expect(router.currentRoute == .settings)
    }

    @Test func replacesPathForNativeBackAndDeepLinks() {
        let router = StackRouter(root: Screen.home)
        router.setPath([.detail(1), .detail(2)])
        router.setPath([.detail(1)])
        #expect(router.path == [.detail(1)])
        #expect(router.root == .home)
    }

    @Test func observesRootAndNestedPathChanges() {
        let router = StackRouter(root: Screen.home)
        let rootChange = ChangeFlag()
        withObservationTracking { _ = router.root } onChange: { rootChange.mark() }
        router.replaceRoot(.settings)
        #expect(rootChange.changed)
        let pathChange = ChangeFlag()
        withObservationTracking { _ = router.currentRoute } onChange: { pathChange.mark() }
        router.push(.detail(1))
        #expect(pathChange.changed)
    }
}
