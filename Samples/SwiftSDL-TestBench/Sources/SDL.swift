@_exported import SwiftSDL

@main struct SDL: ParsableCommand {
  static let configuration = CommandConfiguration(
    groupedSubcommands: [
      .init(name: "test", subcommands: [Test.self])
    ]
  )
}

extension SDL {
  struct Test: ParsableCommand {
    typealias Options = GameOptions
    
    static let configuration = CommandConfiguration(
      abstract: "Run a variety SDL tests reimplemented using SwiftSDL.",
      subcommands: [
        AudioInfo.self,
        Camera.self,
        Controller.self,
        Geometry.self,
        SpinningCube.self,
        Sandbox.self,
        Sprite.self,
      ]
    )
  }
}

func Load(bitmap: String) throws(SDL_Error) -> any Surface {
  try SDL_Load(
    bitmap: bitmap,
    searchingBundles: Bundle.resourceBundles(matching: {
      $0.lastPathComponent.contains("SwiftSDL-TestBench")
    })
  )
}
