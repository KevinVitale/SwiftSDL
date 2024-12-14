// MARK: - Protocol
public protocol Renderer: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: Renderer { }

// MARK: - Create Renderer
public func SDL_CreateRenderer<P: PropertyValue>(with properties: (String, value: P)..., window: (any Window)? = nil) throws(SDL_Error) -> some Renderer {
  try SDL_CreateRenderer(with: properties, window: window)
}

public func SDL_CreateRenderer<P: PropertyValue>(with properties: [(String, value: P)], window: (any Window)? = nil) throws(SDL_Error) -> some Renderer {
  let rendererProperties = SDL_CreateProperties()
  defer { rendererProperties.destroy() }
  
  for property in properties {
    guard rendererProperties.set(property.0, value: property.value) else {
      throw .error
    }
  }
  
  if var windowPointer = window?.pointer {
    rendererProperties.set(
      SDL_PROP_RENDERER_CREATE_WINDOW_POINTER,
      value: withUnsafeMutableBytes(of: &windowPointer, \.baseAddress)
    )
  }

  guard let pointer = SDL_CreateRendererWithProperties(rendererProperties) else {
    throw .error
  }
  
  return SDLObject(pointer, tag: .custom("renderer"), destroy: SDL_DestroyRenderer)
}

// MARK: - Computed Properties
extension Renderer {
  public var name: Result<String, SDL_Error> {
    return self
      .resultOf(SDL_GetRendererName)
      .map({ String(cString: $0) })
  }
  
  public var properties: Result<SDL_PropertiesID, SDL_Error> {
    self.resultOf(SDL_GetRendererProperties)
  }
  
  @discardableResult
  public func set<P: PropertyValue>(property: String, value: P) throws(SDL_Error) -> SDL_PropertiesID {
    let properties = try self.properties.get()
    guard properties.set(property, value: value) else {
      throw .error
    }
    return properties
  }

  public var viewport: Result<Rect<Int32>, SDL_Error> {
    var rect = SDL_Rect()
    return self
      .resultOf(SDL_GetRenderViewport, .some(&rect))
      .map({ _ in [rect.x, rect.y, rect.w, rect.h] })
  }
  
  public var safeArea: Result<Rect<Int32>, SDL_Error> {
    var rect = SDL_Rect()
    return self
      .resultOf(SDL_GetRenderSafeArea, .some(&rect))
      .map({ _ in [rect.x, rect.y, rect.w, rect.h] })
  }
  
  public var logicalSize: Result<Size<Int32>, SDL_Error> {
    var width: Int32 = 0, height: Int32 = 0
    return self
      .resultOf(SDL_GetRenderLogicalPresentation, .some(&width), .some(&height), nil)
      .map({ _ in [width, height] })
  }
  
  public var logicalPresentation: Result<SDL_RendererLogicalPresentation, SDL_Error> {
    var mode: SDL_RendererLogicalPresentation = .disabled
    return self
      .resultOf(SDL_GetRenderLogicalPresentation, nil, nil, .some(&mode))
      .map({ _ in mode })
  }

  public var vsync: Result<Int32, SDL_Error> {
    var vsync: Int32 = 0
    return self
      .resultOf(SDL_GetRenderVSync, .some(&vsync))
      .map({ _ in vsync })
  }
  
  public var blendMode: Result<SDL_BlendMode, SDL_Error> {
    var blendMode: SDL_BlendMode.RawValue = 0
    return self
      .resultOf(SDL_GetRenderDrawBlendMode, .some(&blendMode))
      .map({ _ in SDL_BlendMode(rawValue: blendMode) ?? .invalid })
  }
}

// MARK: - Modes
extension Renderer {
  @discardableResult
  public func set(blendMode: SDL_BlendMode) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderDrawBlendMode, blendMode.rawValue)
  }
  
  @discardableResult
  public func set(vsync: Int32) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderVSync, vsync)
  }
}

// MARK: - Color Functions
extension Renderer {
  public var color: Result<SDL_Color, SDL_Error> {
    var r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0, a: UInt8 = 0
    return self
      .resultOf(SDL_GetRenderDrawColor, .some(&r), .some(&g), .some(&b), .some(&a))
      .map({ _ in SDL_Color(r: r, g: g, b: b, a: a) })
  }
  
  @discardableResult
  public func set(color r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) throws(SDL_Error) -> Self {
    try set(color: SDL_Color(r: r, g: g, b: b, a: a))
  }

  @discardableResult
  public func set(color: SDL_Color) throws(SDL_Error) -> Self {
    let red = Float(color.r) / Float(UInt8.max)
    let green = Float(color.g) / Float(UInt8.max)
    let blue = Float(color.b) / Float(UInt8.max)
    let alpha = Float(color.a) / Float(UInt8.max)
    
    return try self(SDL_SetRenderDrawColorFloat, red, green, blue, alpha)
  }
  
  @discardableResult
  public func clear(color: SDL_Color? = nil) throws(SDL_Error) -> Self {
    if let color {
      try self.set(color: color)
    }
    return try self(SDL_RenderClear)
  }
  
  @discardableResult
  public func clear(color r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8 = .max) throws(SDL_Error) -> Self {
    try self.clear(color: .init(r: r, g: g, b: b, a: a))
  }
}
  
// MARK: - Drawing
extension Renderer {
  @discardableResult
  public func present() throws(SDL_Error) -> Self {
    try self(SDL_RenderPresent)
  }
  
  @discardableResult
  public func pass(to callback: ((_ renderer: Self) throws -> Void)?) throws(SDL_Error) -> any Renderer {
    do {
      try callback?(self)
      return self
    }
    catch let error as SDL_Error {
      throw error
    }
    catch {
      fatalError("Unknown error type thrown: \(error). This should never happen.")
    }
  }

  @discardableResult
  public func pass<each Argument>(to callback: (_ renderer: Self, repeat each Argument) throws(SDL_Error) -> Void, _ argument: repeat each Argument) throws(SDL_Error) -> any Renderer {
    try callback(self, repeat each argument)
    return self
  }
}

extension String {
  @discardableResult
  public static func debugFontSize<T: SIMDScalar>(as type: T.Type) -> T where T: FixedWidthInteger {
    T(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE)
  }
  
  @discardableResult
  public static func debugFontSize<T: SIMDScalar>(as type: T.Type) -> T where T: BinaryFloatingPoint {
    T(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE)
  }

  @discardableResult
  public func debugTextSize<T: SIMDScalar>(as type: T.Type) -> Size<T> where T: FixedWidthInteger {
    [
      Self.debugFontSize(as: type) * T(self.count),
      Self.debugFontSize(as: type)
    ]
  }
    
  @discardableResult
  public func debugTextSize<T: SIMDScalar>(as type: T.Type) -> Size<T> where T: BinaryFloatingPoint {
    [
      Self.debugFontSize(as: type) * T(self.count),
      Self.debugFontSize(as: type)
    ]
  }
}
  
// MARK: - Sizing Functions
extension Renderer {
  @discardableResult
  public func outputSize<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: FixedWidthInteger {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetRenderOutputSize, .some(&width), .some(&height)) else {
      throw .error
    }
    return [T(width), T(height)]
  }
  
  @discardableResult
  public func outputSize<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: BinaryFloatingPoint {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetRenderOutputSize, .some(&width), .some(&height)) else {
      throw .error
    }
    return [T(width), T(height)]
  }
  
  @discardableResult
  public func set<T: SIMDScalar>(logicalSize size: Size<T>, presentation: SDL_RendererLogicalPresentation) throws(SDL_Error) -> Self where T: FixedWidthInteger {
    let sizeAsInt32 = size.to(Int32.self)
    let width = sizeAsInt32.x, height = sizeAsInt32.y
    guard case(.success) = self.resultOf(SDL_SetRenderLogicalPresentation, width, height, presentation) else {
      throw .error
    }
    return self
  }
  
  @discardableResult
  public func set<T: SIMDScalar>(logicalSize size: Size<T>, presentation: SDL_RendererLogicalPresentation) throws(SDL_Error) -> Self where T: BinaryFloatingPoint {
    let sizeAsInt32 = size.to(Int32.self)
    let width = sizeAsInt32.x, height = sizeAsInt32.y
    guard case(.success) = self.resultOf(SDL_SetRenderLogicalPresentation, width, height, presentation) else {
      throw .error
    }
    return self
  }
  
  @discardableResult
  public func set(viewport rect: UnsafePointer<SDL_Rect>! = nil) throws(SDL_Error) -> Self {
    guard case(.success) = self.resultOf(SDL_SetRenderViewport, rect) else {
      throw .error
    }
    return self
  }
  
  @discardableResult
  public func set(viewport rect: SDL_Rect) throws(SDL_Error) -> Self {
    var rect = rect
    return try self.set(viewport: .some(&rect))
  }
  
  @discardableResult
  public func set<T: SIMDScalar>(viewport rect: Rect<T>) throws(SDL_Error) -> Self where T: FixedWidthInteger {
    var rect = SDL_Rect(rect.to(Int32.self))
    return try self.set(viewport: .some(&rect))
  }
  
  @discardableResult
  public func set<T: SIMDScalar>(viewport rect: Rect<T>) throws(SDL_Error) -> Self where T: BinaryFloatingPoint {
    var rect = SDL_Rect(rect.to(Int32.self))
    return try self.set(viewport: .some(&rect))
  }
  
  @discardableResult
  public func set<T: SIMDScalar>(viewport rect: Result<Rect<T>, SDL_Error>) throws(SDL_Error) -> Self where T: FixedWidthInteger {
    var rect = SDL_Rect(try rect.get().to(Int32.self))
    return try self.set(viewport: .some(&rect))
  }
  
  @discardableResult
  public func set<T: SIMDScalar>(viewport rect: Result<Rect<T>, SDL_Error>) throws(SDL_Error) -> Self where T: BinaryFloatingPoint {
    var rect = SDL_Rect(try rect.get().to(Int32.self))
    return try self.set(viewport: .some(&rect))
  }
}
  
// MARK: - Fill Rects/Points/Lines
extension Renderer {
  @discardableResult
  public func points(_ points: SDL_FPoint..., color r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) throws(SDL_Error) -> Self {
    try self.points(points, color: SDL_Color(r: r, g: g, b: b, a: a))
  }
  
  @discardableResult
  public func points(_ points: SDL_FPoint..., color: SDL_Color) throws(SDL_Error) -> Self {
    try self.points(points, color: color)
  }
  
  @discardableResult
  public func points(_ points: [SDL_FPoint], color r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) throws(SDL_Error) -> Self {
    try self.points(points, color: SDL_Color(r: r, g: g, b: b, a: a))
  }

  @discardableResult
  public func points(_ points: [SDL_FPoint], color fillColor: SDL_Color) throws(SDL_Error) -> Self {
    let color = try color.get()
    return try self
      .set(color: fillColor)
      .callAsFunction(
        SDL_RenderPoints,
        points.withUnsafeBufferPointer(\.baseAddress),
        Int32(points.count)
      )
      .set(color: color)
  }
  
  @discardableResult
  public func lines(_ lines: SDL_FPoint..., color r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) throws(SDL_Error) -> Self {
    try self.lines(lines, color: SDL_Color(r: r, g: g, b: b, a: a))
  }
  
  @discardableResult
  public func lines(_ lines: SDL_FPoint..., color: SDL_Color) throws(SDL_Error) -> Self {
    try self.lines(lines, color: color)
  }
  
  @discardableResult
  public func lines(_ lines: [SDL_FPoint], color r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) throws(SDL_Error) -> Self {
    try self.lines(lines, color: SDL_Color(r: r, g: g, b: b, a: a))
  }
  
  @discardableResult
  public func lines(_ lines: [SDL_FPoint], color fillColor: SDL_Color) throws(SDL_Error) -> Self {
    let color = try color.get()
    return try self
      .set(color: fillColor)
      .callAsFunction(
        SDL_RenderLines,
        lines.withUnsafeBufferPointer(\.baseAddress),
        Int32(lines.count)
      )
      .set(color: color)
  }

  @discardableResult
  public func fill(rects: SDL_FRect..., color r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) throws(SDL_Error) -> Self {
    try self.fill(rects: rects, color: SDL_Color(r: r, g: g, b: b, a: a))
  }

  @discardableResult
  public func fill(rects: SDL_FRect..., color: SDL_Color) throws(SDL_Error) -> Self {
    try self.fill(rects: rects, color: color)
  }
  
  @discardableResult
  public func fill(rects: [SDL_FRect], color r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) throws(SDL_Error) -> Self {
    try self.fill(rects: rects, color: SDL_Color(r: r, g: g, b: b, a: a))
  }

  @discardableResult
  public func fill(rects: [SDL_FRect], color fillColor: SDL_Color) throws(SDL_Error) -> Self {
    let color = try color.get()
    return try self
      .set(color: fillColor)
      .callAsFunction(
        SDL_RenderFillRects,
        rects.withUnsafeBufferPointer(\.baseAddress),
        Int32(rects.count)
      )
      .set(color: color)
  }
  
  @discardableResult
  public func set(scale: Size<Float>) throws(SDL_Error) -> Self {
    return try self(SDL_SetRenderScale, scale.x, scale.y)
  }
  
  public var scale: Result<Size<Float>, SDL_Error> {
    var scaleX: Float = 0, scaleY: Float = 0
    return self
      .resultOf(SDL_GetRenderScale, .some(&scaleX), .some(&scaleY))
      .map({ _ in [scaleX, scaleY] })
  }
}

extension Renderer {
  @discardableResult
  public func debug(text: String, position: Point<Float>, color fillColor: SDL_Color = .black, scale: Size<Float> = .one) throws(SDL_Error) -> Self {
    let renderColor = try self.color.get()
    let renderScale = try self.scale.get()
    
    try self
      .set(color: fillColor)
      .set(scale: scale)
    
    guard SDL_RenderDebugText(pointer, position.x, position.y, text) else {
      throw .error
    }
    
    return try self
      .set(color: renderColor)
      .set(scale: renderScale)
  }
}

// MARK: - Logical Presentation
extension SDL_RendererLogicalPresentation: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let disabled = SDL_LOGICAL_PRESENTATION_DISABLED
  public static let stretch = SDL_LOGICAL_PRESENTATION_STRETCH
  public static let letterbox = SDL_LOGICAL_PRESENTATION_LETTERBOX
  public static let overscan = SDL_LOGICAL_PRESENTATION_OVERSCAN
  public static let integerScale = SDL_LOGICAL_PRESENTATION_INTEGER_SCALE
  
  public var debugDescription: String {
    switch self {
      case SDL_LOGICAL_PRESENTATION_DISABLED: return "disabled"
      case SDL_LOGICAL_PRESENTATION_STRETCH: return "stretch"
      case SDL_LOGICAL_PRESENTATION_LETTERBOX: return "letterbox"
      case SDL_LOGICAL_PRESENTATION_OVERSCAN: return "overscan"
      case SDL_LOGICAL_PRESENTATION_INTEGER_SCALE: return "integer scale"
      default: return "Unknown SDL_RendererLogicalPresentation: \(self.rawValue)"
    }
  }
  
  public static var allCases: [SDL_RendererLogicalPresentation] {
    [
      SDL_LOGICAL_PRESENTATION_DISABLED,
      SDL_LOGICAL_PRESENTATION_STRETCH,
      SDL_LOGICAL_PRESENTATION_LETTERBOX,
      SDL_LOGICAL_PRESENTATION_OVERSCAN,
      SDL_LOGICAL_PRESENTATION_INTEGER_SCALE
    ]
  }
}
