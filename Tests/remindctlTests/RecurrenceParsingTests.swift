import Testing

@testable import RemindCore
@testable import remindctl

@MainActor
struct RecurrenceParsingTests {
  @Test("Parse repeat presets")
  func parsePresets() throws {
    #expect(try CommandHelpers.parseRecurrence("daily") == RecurrenceRule(frequency: .daily))
    #expect(try CommandHelpers.parseRecurrence("weekly") == RecurrenceRule(frequency: .weekly))
    #expect(try CommandHelpers.parseRecurrence("biweekly") == RecurrenceRule(frequency: .weekly, interval: 2))
    #expect(try CommandHelpers.parseRecurrence("monthly") == RecurrenceRule(frequency: .monthly))
    #expect(try CommandHelpers.parseRecurrence("yearly") == RecurrenceRule(frequency: .yearly))
  }

  @Test("Parse custom repeat interval")
  func parseCustomInterval() throws {
    #expect(try CommandHelpers.parseRecurrence("every 3 days") == RecurrenceRule(frequency: .daily, interval: 3))
    #expect(try CommandHelpers.parseRecurrence("every 4 weeks") == RecurrenceRule(frequency: .weekly, interval: 4))
    #expect(try CommandHelpers.parseRecurrence("every 6 months") == RecurrenceRule(frequency: .monthly, interval: 6))
    #expect(try CommandHelpers.parseRecurrence("every 2 years") == RecurrenceRule(frequency: .yearly, interval: 2))
  }

  @Test("Reject invalid repeat interval")
  func rejectInvalidInterval() {
    #expect(throws: (any Error).self) {
      try CommandHelpers.parseRecurrence("every 0 weeks")
    }
    #expect(throws: (any Error).self) {
      try CommandHelpers.parseRecurrence("weekdaily")
    }
  }
}
