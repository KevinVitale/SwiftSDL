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
    struct Options: ParsableArguments {
      @Flag(help: "Create a borderless window") var noFrame: Bool = false
      @Flag(help: "Create a minimized window") var minimized: Bool = false
      @Flag(help: "Create a maximized window") var maximized: Bool = false
      @Flag(help: "Enable vertical synchronization") var vsync: Bool = false
      
      // @Option(help: "Specify the render's scale (WxH)") var renderScale: SDL_Size = .one
      
      @Flag(help: "Enable window resizability") var windowResizable: Bool = false
      @Option(help: "Specify the window's title") var windowTitle: String?
      @Option(help: "Specify the window's position (XxY)") var windowPosition: SDL_Point?
      @Option(help: "Specify the window's size (WxH)") var windowSize: SDL_Size?
      @Option(help: "Specify the minimum window's size (WxH)") var minWindowSize: SDL_Size?
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Run a variety SDL tests reimplemented using SwiftSDL.",
      subcommands: [
        AudioInfo.self,
        Camera.self,
        Controller.self,
        Geometry.self,
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

extension SDL_Point: @retroactive ExpressibleByArgument {
  public init?(argument: String) {
    let width = Int32(argument.split(separator: "x").first ?? "0") ?? .zero
    let height = Int32(argument.split(separator: "x").last ?? "0") ?? .zero
    self.init(x: width, y: height)
  }
}

extension Window {
  func sync(options: SDL.Test.Options) throws(SDL_Error) {
    if let windowTitle    = options.windowTitle { try set(title: windowTitle) }
    if let windowMinSize  = options.minWindowSize { try set(minSize: windowMinSize) }
    if let windowSize     = options.windowSize { try set(size: windowSize) }
    if let windowPosition = options.windowPosition { try set(position: windowPosition) }
    
    if !has(.resizable)  { try set(resizable: options.windowResizable) }
    if !has(.borderless) { try set(showBorder: !options.noFrame) }
    if !has(.minimized) && options.minimized { try self(SDL_MinimizeWindow) }
    if !has(.maximized) && options.maximized { try self(SDL_MaximizeWindow) }
    
    try self(SDL_SyncWindow)
  }
}
