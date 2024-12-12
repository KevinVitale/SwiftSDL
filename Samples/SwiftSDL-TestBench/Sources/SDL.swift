@_exported import SwiftSDL

@main struct SDL: ParsableCommand {
  static let configuration = CommandConfiguration(
    groupedSubcommands: [
      .init(name: "games", subcommands: [Games.self]),
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
        Sprite.self,
      ]
    )
  }
}

extension SDL {
  struct Games: ParsableCommand {
    typealias Options = GameOptions
    
    static let configuration = CommandConfiguration(
      abstract: "Run a variety SDL game examples implemented using SwiftSDL.",
      subcommands: [
        FlappyBird.self,
        Sandbox.self,
        StinkyDuck.self
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
