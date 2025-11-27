public struct GameOptions: ParsableArguments {
  public init() { }
  
  @Flag(help: "Hide the system's cursor")
  public var hideCursor: Bool = false
  
  @Flag(help: "Stretch the content to fill the window")
  public var autoScaleContent: Bool = false
  
  @Option(help: "Forces the rendered content to be a certain logical size (WxH)")
  public var renderLogicalSize: SDL_Size? = nil
  
  @Option(help: "Forces the rendered content to be a certain logical order; overrides '--auto-scale-content'")
  public var renderLogicalPresentation: SDL_RendererLogicalPresentation = .disabled
  
  @Option(help: "Set vertical synchronization rate")
  public var renderVsync: VSyncRate = .disabled
  
  @Flag(help: "Window is always kept on top")
  public var windowAlwaysOnTop: Bool = false
  
  @Flag(help: "Window is set to fullscreen")
  public var windowFullscreen: Bool = false
  
  @Flag(help: "Window is uses a transparent buffer")
  public var windowTransparent: Bool = false
  
  @Flag(help: "Create a maximized window; requires '--window-resizable'")
  public var windowMaximized: Bool = false
  
  @Flag(help: "Create a minimized window")
  public var windowMinimized: Bool = false
  
  @Option(help: "Specify the maximum window's size (WxH)")
  public var windowMaxSize: SDL_Size?
  
  @Option(help: "Specify the minimum window's size (WxH)")
  public var windowMinSize: SDL_Size?
  
  @Flag(help: "Force the window to have mouse focus")
  public var windowMouseFocus: Bool = false
  
  @Flag(help: "Create a borderless window")
  public var windowNoFrame: Bool = false
  
  @Flag(help: "Enable window resizability")
  public var windowResizable: Bool = false
  
  @Option(help: "Specify the window's position (XxY)")
  public var windowPosition: SDL_Point?
  
  @Option(help: "Specify the window's size (WxH)")
  public var windowSize: SDL_Size?
  
  @Option(help: "Specify the window's title")
  public var windowTitle: String?
}

extension GameOptions {
  public enum VSyncRate: RawRepresentable, ExpressibleByArgument, Decodable {
    public init?(argument: String) {
      switch argument.lowercased() {
        case "adaptive": self = .adaptive
        case let value where Int(value) != nil:
          let value = Int32(value)!
          self = value != 0 ? .enabled(value) : .disabled
        default: self = .disabled
      }
    }
    
    public init?(rawValue: Int32) {
      switch rawValue {
        case -1: self = .adaptive
        case 0: self = .disabled
        default: self = .enabled(rawValue)
      }
    }
    
    case adaptive
    case disabled
    case enabled(Int32)
    
    public var rawValue: RawValue {
      switch self {
        case .adaptive: return -1
        case .enabled(let value): return value
        case .disabled: return 0
      }
    }
    
    public var defaultValueDescription: String {
      switch self {
        case .adaptive: return "adaptive"
        case .enabled: return "enabled"
        case .disabled: return "disabled"
      }
    }
    
    public static var allValueStrings: [String] {
      [
        "adaptive",
        "disabled",
        "interger value"
      ]
    }
  }
}

extension Window {
  internal func sync(options: GameOptions) throws(SDL_Error) {
    // Must have 'resizable' before 'maximized'
    if isNot(.resizable)  { try set(resizable: options.windowResizable) }
    
    if let windowMinSize  = options.windowMinSize { try set(minSize: windowMinSize) }
    if let windowMaxSize  = options.windowMaxSize { try set(maxSize: windowMaxSize) }
    if let windowPosition = options.windowPosition { try set(position: windowPosition) }
    if let windowSize     = options.windowSize { try set(size: windowSize) }
    if let windowTitle    = options.windowTitle { try set(title: windowTitle) }
    
    /// These checks ensure that flags which have already been set aren't overwritten.
    if isNot(.always_on_top) { try set(alwaysOnTop: options.windowAlwaysOnTop) }
    if isNot(.minimized) && options.windowMinimized { try self(SDL_MinimizeWindow) }
    if isNot(.maximized) && options.windowMaximized {
      /*
      if isNot(.resizable) {
        try self(SDL_SetWindowResizable, true)
      }
       */
      try self(SDL_MaximizeWindow)
    }
    if isNot(.mouse_focus) { try set(mouseFocus: options.windowMouseFocus) }
    if isNot(.borderless) { try set(showBorder: !options.windowNoFrame) }
    if isNot(.fullscreen) { try self(SDL_SetWindowFullscreen, options.windowFullscreen) }
    
    _ = options.hideCursor ? SDL_HideCursor() : SDL_ShowCursor()
    
    if let renderer = try? renderer.get() {
      if try renderer.vsync.get() == 0, options.renderVsync != .disabled {
        SDL_Log("Attempting to set vsync to \"\(options.renderVsync)\"")
        try renderer.set(vsync: options.renderVsync.rawValue)
      }
      
      let existingLogicalSize = SDL_Size(try renderer.logicalSize.get())
      let existingLogicalPres = try renderer.logicalPresentation.get()
      
      var logicalSize         = options.renderLogicalSize ?? existingLogicalSize
      let logicalPresentation = options.autoScaleContent ? .stretch : (existingLogicalPres != .disabled ? existingLogicalPres : options.renderLogicalPresentation)
      
      // Mirrors 'logicalSize' to `window.size` when empty...
      if logicalSize.x == 0, logicalSize.y == 0 {
        logicalSize = try self.size(as: SDL_Size.self)
      }
      
      SDL_Log("Attempting to set logical size to: \(logicalSize.x)x\(logicalSize.y); presentation: \(logicalPresentation)")
      try renderer.set(logicalSize: [logicalSize.x, logicalSize.y], presentation: logicalPresentation)
    }
    
    try self(SDL_SyncWindow)
  }
}

extension SDL_RendererLogicalPresentation: @retroactive ExpressibleByArgument { }

extension SDL_Point: @retroactive ExpressibleByArgument {
  public init?(argument: String) {
    let width = Int32(argument.split(separator: "x").first ?? "0") ?? .zero
    let height = Int32(argument.split(separator: "x").last ?? "0") ?? .zero
    self.init(x: width, y: height)
  }
}

extension SDL_FPoint: @retroactive ExpressibleByArgument {
  public init?(argument: String) {
    let width = Float(argument.split(separator: "x").first ?? "0") ?? .zero
    let height = Float(argument.split(separator: "x").last ?? "0") ?? .zero
    self.init(x: width, y: height)
  }
}
