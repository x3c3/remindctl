import Foundation
import RemindCore

enum ReminderLinks {
  static func reminderURL(id: String) -> URL {
    URL(string: "x-apple-reminderkit://REMCDReminder/\(encode(id))")!
  }

  static func listURL(id: String) -> URL {
    URL(string: "x-apple-reminderkit://REMCDList/\(encode(id))")!
  }

  private static func encode(_ value: String) -> String {
    value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
  }
}
