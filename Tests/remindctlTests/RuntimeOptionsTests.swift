import Testing

@testable import remindctl

struct RuntimeOptionsTests {
  @Test("Runtime format validation rejects unknown values")
  func rejectsUnknownFormat() throws {
    #expect(try RuntimeOptions.outputFormat(named: "json") == .json)
    #expect(try RuntimeOptions.outputFormat(named: "table") == .table)
    #expect(throws: Error.self) {
      _ = try RuntimeOptions.outputFormat(named: "jsn")
    }
  }
}
