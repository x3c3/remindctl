import Commander
import Foundation
import RemindCore

struct LinkResult: Codable, Sendable, Equatable {
  let kind: String
  let id: String
  let title: String
  let url: String
}

enum LinkCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "link",
      abstract: "Print a Reminders deep link",
      discussion: "Prints a best-effort Reminders URL for a reminder or list.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          arguments: [
            .make(label: "id", help: "Reminder index or ID prefix", isOptional: true)
          ],
          options: [
            .make(label: "list", names: [.short("l"), .long("list")], help: "List name", parsing: .singleValue),
            .make(label: "listID", names: [.long("list-id")], help: "List ID or ID prefix", parsing: .singleValue),
          ]
        )
      ),
      usageExamples: [
        "remindctl link 1",
        "remindctl link 4A83 --json",
        "remindctl link --list Work",
        "remindctl link --list-id 7A12",
      ]
    ) { values, runtime in
      let result = try await resolve(values: values)
      print(result, format: runtime.outputFormat)
    }
  }

  static func resolve(values: ParsedValues) async throws -> LinkResult {
    let store = RemindersStore()
    try await store.requestAccess()

    if let target = try CommandHelpers.listTarget(name: values.option("list"), id: values.option("listID")) {
      if values.argument(0) != nil {
        throw RemindCoreError.operationFailed("Use a reminder id or list target, not both")
      }
      let list = try await store.resolveList(target)
      return LinkResult(
        kind: "list", id: list.id, title: list.title, url: ReminderLinks.listURL(id: list.id).absoluteString)
    }

    guard let input = values.argument(0) else {
      throw ParsedValuesError.missingArgument("id")
    }
    let reminders = try await store.reminders(in: nil)
    guard let reminder = try CommandHelpers.resolveShowIdentifiers([input], from: reminders).first else {
      throw RemindCoreError.reminderNotFound(input)
    }
    return LinkResult(
      kind: "reminder",
      id: reminder.id,
      title: reminder.title,
      url: ReminderLinks.reminderURL(id: reminder.id).absoluteString
    )
  }

  static func print(_ result: LinkResult, format: OutputFormat) {
    switch format {
    case .json:
      OutputRenderer.printJSON(result)
    case .plain, .quiet:
      Swift.print(result.url)
    case .standard, .table:
      Swift.print(result.url)
    }
  }
}
