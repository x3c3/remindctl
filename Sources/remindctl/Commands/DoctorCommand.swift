import Commander
import Foundation
import RemindCore

struct DoctorReport: Codable, Sendable, Equatable {
  let authorization: AuthorizationSummary
  let executable: String
  let shell: String?
  let richRead: RichReadDiagnostics
  let agentNotes: [String]
}

enum DoctorCommand {
  static var spec: CommandSpec {
    CommandSpec(
      name: "doctor",
      abstract: "Diagnose setup and permissions",
      discussion: "Reports Reminders authorization and read-only rich-store diagnostics for this process.",
      signature: CommandSignatures.withRuntimeFlags(
        CommandSignature(
          flags: [
            .make(label: "forAgent", names: [.long("for-agent")], help: "Include agent-focused TCC notes")
          ]
        )
      ),
      usageExamples: [
        "remindctl doctor",
        "remindctl doctor --for-agent --json",
      ]
    ) { values, runtime in
      let status = RemindersStore.authorizationStatus()
      let report = DoctorReport(
        authorization: AuthorizationSummary(status: status.rawValue, authorized: status.isAuthorized),
        executable: CommandLine.arguments.first ?? "remindctl",
        shell: ProcessInfo.processInfo.environment["SHELL"],
        richRead: RichReadDiagnostics.collect(),
        agentNotes: values.flag("forAgent") ? PermissionsHelp.guidanceLines(for: status) : []
      )

      switch runtime.outputFormat {
      case .json:
        OutputRenderer.printJSON(report)
      case .plain, .quiet:
        Swift.print(status.rawValue)
      case .standard, .table:
        Swift.print("Reminders access: \(status.displayName)")
        Swift.print("Executable: \(report.executable)")
        Swift.print("Rich read store: \(report.richRead.readable ? "readable" : "not readable")")
        if let databasePath = report.richRead.databasePath {
          Swift.print("Database: \(databasePath)")
        }
        for (name, count) in report.richRead.tableCounts.sorted(by: { $0.key < $1.key }) {
          Swift.print("\(name): \(count)")
        }
        if let error = report.richRead.error {
          Swift.print("Rich read warning: \(error)")
        }
        for line in report.agentNotes {
          Swift.print(line)
        }
      }
    }
  }
}
