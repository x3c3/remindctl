import Testing

@testable import remindctl

struct ReminderLinksTests {
  @Test("Reminder links use Reminders entity URL kinds")
  func entityKinds() {
    #expect(ReminderLinks.reminderURL(id: "REM-1").absoluteString == "x-apple-reminderkit://REMCDReminder/REM-1")
    #expect(ReminderLinks.listURL(id: "LIST-1").absoluteString == "x-apple-reminderkit://REMCDList/LIST-1")
  }
}
