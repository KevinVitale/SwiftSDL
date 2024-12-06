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
      throw SDL_Error.error
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

  public func size<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: FixedWidthInteger {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetWindowSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return [T(width), T(height)]
  }
  
  public func size<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: BinaryFloatingPoint {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetWindowSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return [T(width), T(height)]
  }
  
  public func size<T: SIMD>(as type: T.Type) throws(SDL_Error) -> T where T.Scalar: FixedWidthInteger {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetWindowSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return T([T.Scalar(width), T.Scalar(height)])
  }
  
  public func size<T: SIMD>(as type: T.Type) throws(SDL_Error) -> T where T.Scalar: BinaryFloatingPoint {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetWindowSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return T([T.Scalar(width), T.Scalar(height)])
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
      throw SDL_Error.error
    }
    return self
  }

  @discardableResult
  public func updateSurface() throws(SDL_Error) -> some Window {
    try self(SDL_UpdateWindowSurface)
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
      throw SDL_Error.error
    }
  }
  
  guard let pointer = SDL_CreateWindowWithProperties(windowProperties) else {
    throw SDL_Error.error
  }
  
  return SDLObject(pointer, tag: .custom("app window"), destroy: SDL_DestroyWindow)
}

public func SDL_CreateWindow(_ title: String, size: Size<Int32>, flags: SDL_WindowFlags) throws(SDL_Error) -> some Window {
  guard let pointer = SDL_CreateWindow(title, size.x, size.y, flags.rawValue) else {
    throw SDL_Error.error
  }
  return SDLObject(pointer, tag: .custom("app window"), destroy: SDL_DestroyWindow)
}

@discardableResult
public func SDL_GetWindows() throws(SDL_Error) -> [any Window] {
  var count: UInt32 = 0
  guard let windows = SDL_GetWindows(&count) else {
    throw SDL_Error.error
  }
  
  defer { SDL_free(windows) }
  
  return Array<OpaquePointer?>.init(unsafeUninitializedCapacity: Int(count)) { buffer, initializedCount in
    initializedCount = Int(count)
    for i in 0..<initializedCount {
      buffer[i] = windows[i]
    }
  }
    .compactMap(\.self)
    .map({ SDLObject($0, tag: .custom("tag"), destroy: SDL_DestroyWindow) })
}
