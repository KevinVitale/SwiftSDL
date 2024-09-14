import class Foundation.Bundle
import Testing
@testable import SwiftSDL

@Test func testGame() async throws {
  try await App.run(TestGame.self)
}

@Test func testCamera() async throws {
  try await App.run(CameraGame.self)
}
