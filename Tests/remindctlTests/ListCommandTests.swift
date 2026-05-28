import Testing

@testable import remindctl

@MainActor
struct ListCommandTests {
  @Test("Multiple list names are allowed for read-only listing")
  func multipleNamesAllowedForListing() throws {
    let name = try ListCommand.singleListName(["Work", "Home"], forMutation: false)
    #expect(name == "Work")
  }

  @Test("Multiple list names are rejected for mutations")
  func multipleNamesRejectedForMutations() {
    #expect(throws: Error.self) {
      _ = try ListCommand.singleListName(["Work", "Home"], forMutation: true)
    }
  }

  @Test("Multiple list names keep read-only multi-list behavior")
  func multipleNamesUseMultiListReadOnlyPath() {
    #expect(ListCommand.shouldReadMultipleLists(names: ["Work", "Home"], listID: nil, isMutation: false))
    #expect(!ListCommand.shouldReadMultipleLists(names: ["Work", "Home"], listID: nil, isMutation: true))
    #expect(!ListCommand.shouldReadMultipleLists(names: ["Work", "Home"], listID: "LIST", isMutation: false))
  }

  @Test("Open command keeps list-constrained filter behavior")
  func openListWithoutAppShowsOpenReminders() {
    #expect(OpenCommand.shouldShowOpenReminders(id: nil, listName: "Work", listID: nil, app: false))
    #expect(OpenCommand.shouldShowOpenReminders(id: nil, listName: nil, listID: "LIST", app: false))
    #expect(!OpenCommand.shouldShowOpenReminders(id: nil, listName: "Work", listID: nil, app: true))
    #expect(!OpenCommand.shouldShowOpenReminders(id: "A123", listName: nil, listID: nil, app: false))
  }
}
