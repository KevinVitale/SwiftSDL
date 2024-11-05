@_exported import SwiftSDL

@main struct SDL: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    groupedSubcommands: [
      .init(name: "test", subcommands: [Test.self])
    ]
  )
}

extension SDL {
  struct Test: AsyncParsableCommand {
    struct Options: ParsableArguments {
      @Flag(help: "Enable vertical synchronization.") var vsync: Bool = false
      @Option(help: "Specify the window's title") var title: String = ""
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Run a variety SDL tests reimplemented using SwiftSDL.",
      subcommands: [
        AudioInfo.self,
        Camera.self,
        // Controller.self,
        Geometry.self,
        Sandbox.self
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
