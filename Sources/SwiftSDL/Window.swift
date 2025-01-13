public protocol Window: SDLObjectProtocol where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: Window { }

extension Window {
  public var id: Result<SDL_WindowID, SDL_Error> {
    self.resultOf(SDL_GetWindowID)
  }
  
  private var flags: UInt64 {
    try! self(SDL_GetWindowFlags)
  }
  
  public func has(_ flag: SDL_WindowFlags) -> Bool {
    flags & flag.rawValue != 0
  }
  
  public var properties: Result<SDL_PropertiesID, SDL_Error> {
    self.resultOf(SDL_GetWindowProperties)
  }
  
  @discardableResult
  public func set<P: PropertyValue>(property: String, value: P) throws(SDL_Error) -> SDL_PropertiesID {
    let properties = try self.properties.get()
    guard properties.set(property, value: value) else {
      throw .error
    }
    return properties
  }

  public var surface: Result<any Surface, SDL_Error> {
    self
      .resultOf(SDL_GetWindowSurface)
      .map({ SDLObject($0, tag: .custom("surface")) })
  }
  
  public var renderer: Result<any Renderer, SDL_Error> {
    self
      .resultOf(SDL_GetRenderer)
      .map({ SDLObject($0, tag: .custom("renderer")) })
  }
  
  public var displayMode: Result<Any, SDL_Error> {
    fatalError()
  }
  
  @discardableResult
  public func createRenderer() throws(SDL_Error) -> any Renderer {
    try self.createRenderer(with: [(String, value: Bool)]())
  }
  
  @discardableResult
  public func createRenderer<P: PropertyValue>(with properties: (String, value: P)...) throws(SDL_Error) -> any Renderer {
    try self.createRenderer(with: properties)
  }
  
  @discardableResult
  public func createRenderer<P: PropertyValue>(with properties: [(String, value: P)] = []) throws(SDL_Error) -> any Renderer {
    try self
      .resultOf(SDL_CreateRenderer, nil)
      .map({ SDLObject($0, tag: .custom("window renderer"), destroy: SDL_DestroyRenderer) })
      .get()
  }
  
  @discardableResult
  public func createGPUDevice(with flags: SDL_GPUShaderFormat..., debugMode: Bool = false, named driver: String? = nil) throws(SDL_Error) -> some GPUDevice {
    try self.createGPUDevice(with: flags, debugMode: debugMode, named: driver)
  }
  
  @discardableResult
  public func createGPUDevice(with flags: [SDL_GPUShaderFormat], debugMode: Bool = false, named driver: String? = nil) throws(SDL_Error) -> some GPUDevice {
    try SDL_CreateGPUDevice(claimFor: self, flags: flags, debugMode: debugMode, named: driver)
  }

  @discardableResult
  public func set(alwaysOnTop: Bool) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowAlwaysOnTop, alwaysOnTop)
  }
  
  @discardableResult
  public func set(mouseFocus: Bool) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowMouseGrab, mouseFocus)
  }

  @discardableResult
  public func set(showBorder: Bool) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowBordered, showBorder)
  }
  
  @discardableResult
  public func set(resizable: Bool) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowResizable, resizable)
  }

  @discardableResult
  public func set(position: Point<Int32>) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowPosition, position.x, position.y)
  }
  
  @discardableResult
  public func set(position: SDL_Point) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowPosition, position.x, position.y)
  }

  public var title: Result<String, SDL_Error> {
    self
      .resultOf(SDL_GetWindowTitle)
      .map(String.init(cString:))
  }

  @discardableResult
  public func set(title: String) throws(SDL_Error) -> some Window {
    // - FIXME: SDL_SetWindowTitle
    // 'callAsFunction' not working as expected?
    // Forced to invoke the C-function explicitly.
    guard SDL_SetWindowTitle(pointer, title.cString(using: .utf8)) else {
      throw .error
    }
    return self
  }

  @discardableResult
  public func updateSurface() throws(SDL_Error) -> some Window {
    try self(SDL_UpdateWindowSurface)
  }
}

// Information on SDL3 window size:
// https://github.com/libsdl-org/SDL/blob/main/docs/README-highdpi.md
extension Window {
  /// Retrieves the window dimensions in native coordinates.
  public func size<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: FixedWidthInteger {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetWindowSize, .some(&width), .some(&height)) else {
      throw .error
    }
    return [T(width), T(height)]
  }
  
  /// Retrieves the window dimensions in native coordinates.
  public func size<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: BinaryFloatingPoint {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetWindowSize, .some(&width), .some(&height)) else {
      throw .error
    }
    return [T(width), T(height)]
  }
  
  /// Retrieves the window dimensions in native coordinates.
  public func size(as type: SDL_Size.Type) throws(SDL_Error) -> SDL_Size {
    return .init(try self.size(as: Int32.self))
  }
  
  /// Retrieves the window dimensions in native coordinates.
  public func size(as type: SDL_FSize.Type) throws(SDL_Error) -> SDL_FSize {
    return .init(try self.size(as: Float.self))
  }
  
  /// Retrieves the window dimensions in pixels-addressable.
  public func pixelSize() throws(SDL_Error) -> Size<Int32> {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetWindowSizeInPixels, .some(&width), .some(&height)) else {
      throw .error
    }
    return [width, height]
  }
  
  /// Retrieves the suggested amplification factor when drawing in native coordinates.
  public var displayScale: Result<Float, SDL_Error> {
    self.resultOf(SDL_GetWindowDisplayScale)
  }
  
  /// Retrieves how many addressable pixels correspond to one unit of native coordinates.
  public var pixelDensity: Result<Float, SDL_Error> {
    self.resultOf(SDL_GetWindowPixelDensity)
  }

  @discardableResult
  public func set(size: Size<Int32>) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowSize, size.x, size.y)
  }
  
  @discardableResult
  public func set(size: SDL_Size) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowSize, size.x, size.y)
  }
  
  @discardableResult
  public func set(minSize size: Size<Int32>) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowMinimumSize, size.x, size.y)
  }
  
  @discardableResult
  public func set(minSize size: SDL_Size) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowMinimumSize, size.x, size.y)
  }
  
  @discardableResult
  public func set(maxSize size: SDL_Size) throws(SDL_Error) -> some Window {
    try self(SDL_SetWindowMaximumSize, size.x, size.y)
  }
}

public func SDL_CreateWindow(with properties: WindowProperty...) throws(SDL_Error) -> some Window {
  try SDL_CreateWindow(with: properties)
}

public func SDL_CreateWindow(with properties: [WindowProperty]) throws(SDL_Error) -> some Window {
  let windowProperties = SDL_CreateProperties()
  defer { windowProperties.destroy() }
  
  for property in properties {
    guard windowProperties.set(property.value.0.rawValue, value: property.value.1) else {
      throw .error
    }
  }
  
  guard let pointer = SDL_CreateWindowWithProperties(windowProperties) else {
    throw .error
  }
  
  return SDLObject(pointer, tag: .custom("app window"), destroy: SDL_DestroyWindow)
}

public func SDL_CreateWindow(_ title: String, size: Size<Int32>, flags: SDL_WindowFlags) throws(SDL_Error) -> some Window {
  guard let pointer = SDL_CreateWindow(title, size.x, size.y, flags.rawValue) else {
    throw .error
  }
  return SDLObject(pointer, tag: .custom("app window"), destroy: SDL_DestroyWindow)
}

@discardableResult
public func SDL_GetWindows() throws(SDL_Error) -> [any Window] {
  try SDL_BufferPointer(SDL_GetWindows)
    .compactMap(\.self)
    .map({ SDLObject($0) as! (any Window) })
}
