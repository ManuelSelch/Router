import Testing
@testable import Router

// No Identifiable, Codable or CaseIterable requirements.
enum AppTab: Hashable { case chats, projects, missing }

@Suite @MainActor
struct TabRouterTests {
    @Test func selectsConfiguredTabsWithoutResettingStacks() throws {
        let chats = StackRouter(root: Screen.home)
        let projects = StackRouter(root: Screen.detail(1))
        let router = try TabRouter(tabs: [
            (.chats, chats), (.projects, projects)
        ], selected: AppTab.chats)
        chats.push(.detail(2))
        #expect(router.select(.projects))
        projects.push(.detail(3))
        #expect(router.select(.chats))
        #expect(router.selected == .chats)
        #expect(router.selectedStack === chats)
        #expect(router.stack(for: .projects) === projects)
        #expect(chats.currentRoute == .detail(2))
        #expect(projects.currentRoute == .detail(3))
        #expect(router.tabs == [.chats, .projects])
    }

    @Test func missingSelectionFailsWithoutMutation() throws {
        let router = try TabRouter(tabs: [(.chats, StackRouter(root: Screen.home))],
                                   selected: AppTab.chats)
        #expect(!router.select(.missing))
        #expect(router.selected == .chats)
        #expect(router.stack(for: .missing) == nil)
    }

    @Test func rejectsInvalidConfiguration() {
        #expect(throws: TabRouterConfigurationError.emptyTabs) {
            try TabRouter<AppTab, Screen>(tabs: [], selected: .chats)
        }
        #expect(throws: TabRouterConfigurationError.duplicateTab) {
            try TabRouter(tabs: [(AppTab.chats, StackRouter(root: Screen.home)),
                                 (.chats, StackRouter(root: Screen.settings))], selected: .chats)
        }
        #expect(throws: TabRouterConfigurationError.unknownSelection) {
            try TabRouter(tabs: [(AppTab.chats, StackRouter(root: Screen.home))], selected: .missing)
        }
    }
}
