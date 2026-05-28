import Testing

@testable import remindctl

@MainActor
struct ExportCommandTests {
  @Test("CSV export neutralizes spreadsheet formula-leading fields")
  func neutralizesSpreadsheetFormulas() {
    #expect(ExportCommand.neutralizeSpreadsheetFormula("=IMPORTXML(\"https://example.com\")").hasPrefix("'="))
    #expect(ExportCommand.neutralizeSpreadsheetFormula(" +SUM(A1:A2)").hasPrefix("' "))
    #expect(ExportCommand.neutralizeSpreadsheetFormula("normal") == "normal")
  }

  @Test("Export output honors runtime output precedence")
  func outputPrecedence() throws {
    #expect(try ExportCommand.outputMode(exportFormat: nil, runtimeFormat: .standard) == .json)
    #expect(try ExportCommand.outputMode(exportFormat: "csv", runtimeFormat: .standard) == .csv)
    #expect(try ExportCommand.outputMode(exportFormat: "csv", runtimeFormat: .json) == .json)
    #expect(try ExportCommand.outputMode(exportFormat: "csv", runtimeFormat: .table) == .rendered(.table))
    #expect(try ExportCommand.outputMode(exportFormat: "csv", runtimeFormat: .quiet) == .rendered(.quiet))
  }
}
