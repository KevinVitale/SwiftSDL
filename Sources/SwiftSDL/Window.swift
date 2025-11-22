extension Window {
  public var properties: Result<SDL_PropertiesID, SDL_Error> {
    self.resultOf(SDL_GetWindowProperties)
      .flatMap { propertyID in
        Result { try SDL_PropertiesID(id: propertyID) }
          .mapError { $0 as! SDL_Error }
      }
  }
  
  public var displayMode: Result<Any, SDL_Error> {
    fatalError()
  }
  
  @discardableResult
  public func createRenderer() throws(SDL_Error) -> any Renderer {
    try self.createRenderer(with: [(String, value: Bool)]())
  }
  
  @discardableResult
  public func createRenderer<P: SDL_PropertyTypeValue>(with properties: (String, value: P)...) throws(SDL_Error) -> any Renderer {
    try self.createRenderer(with: properties)
  }
  
  @discardableResult
  public func createRenderer<P: SDL_PropertyTypeValue>(with properties: [(String, value: P)] = []) throws(SDL_Error) -> any Renderer {
    try self
      .resultOf(SDL_CreateRenderer, nil)
      .map({ SDL_Object($0, tag: "window renderer", destroy: SDL_DestroyRenderer) })
      .get()
  }
  
  @discardableResult
  public func createGPUDevice(with flags: [SDL_GPUShaderFormat] = Array(SDL_GPUShaderFormat.allCases[1...]), debugMode: Bool = false, named driver: String? = nil) throws(SDL_Error) -> some GPUDevice {
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

  @discardableResult
  /** Sets the window's title.
   
   - parameters:
   - title: The window's new title
   
   - warning: `callAsFunction` does not work as expected;
   Use this method instead to invoke the C-function explicitly.
   */
  public func set(title: String) throws(SDL_Error) -> some Window {
    guard __SDL_SetWindowTitle(pointer, title.cString(using: .utf8)) else {
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

@discardableResult
public func SDL_GetWindows() throws(SDL_Error) -> [any Window] {
  try SDL_BufferPointer(__SDL_GetWindows)
    .compactMap(\.self)
    .map({ SDL_Object($0) as! (any Window) })
}
