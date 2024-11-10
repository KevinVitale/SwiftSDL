// MARK: - Protocol
@MainActor
public protocol Renderer: SDLObjectProtocol where Pointer == OpaquePointer { }

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
      throw SDL_Error.error
    }
  }
  
  if var windowPointer = window?.pointer {
    rendererProperties.set(
      SDL_PROP_RENDERER_CREATE_WINDOW_POINTER,
      value: withUnsafeMutableBytes(of: &windowPointer, \.baseAddress)
    )
  }

  guard let pointer = SDL_CreateRendererWithProperties(rendererProperties) else {
    throw SDL_Error.error
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
  
  public var color: Result<SDL_Color, SDL_Error> {
    var r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0, a: UInt8 = 0
    return self
      .resultOf(SDL_GetRenderDrawColor, .some(&r), .some(&g), .some(&b), .some(&a))
      .map({ _ in SDL_Color(r: r, g: g, b: b, a: a) })
  }
  
  public var viewport: Result<Rect<Int32>, SDL_Error> {
    var rect = SDL_Rect()
    return self
      .resultOf(SDL_GetRenderViewport, .some(&rect))
      .map({ _ in [rect.x, rect.y, rect.w, rect.h] })
  }
  
  public var vsync: Result<Int32, SDL_Error> {
    var vsync: Int32 = 0
    return self
      .resultOf(SDL_GetRenderVSync, .some(&vsync))
      .map({ _ in vsync })
  }
  
  @discardableResult
  public func set(vsync: Int32) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderVSync, vsync)
  }
}

// MARK: - Modes
extension Renderer {
  @discardableResult
  public func set(blendMode: Flags.BlendMode) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderDrawBlendMode, blendMode.rawValue)
  }
}

// MARK: - Color Functions
extension Renderer {
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
}
  
// MARK: - Drawing
extension Renderer {
  @discardableResult
  public func present() throws(SDL_Error) -> Self {
    try self(SDL_RenderPresent)
  }
  
  @discardableResult
  public func draw(into callback: (Self) throws -> Void) throws(SDL_Error) -> any Renderer {
    do {
      try callback(self)
      return self
    } catch {
      throw error as! SDL_Error
    }
  }

  @discardableResult
  public func draw(texture: (any Texture)?, position: Point<Float>) throws(SDL_Error) -> Self {
    guard let texture = texture else { return self }
    let size = try texture.size(as: Float.self)
    return try self.draw(
      texture: texture,
      destinationRect: [
        position.x, position.y,
        size.x, size.y
      ]
    )
  }
  
  @discardableResult
  public func draw(texture: (any Texture)?, destinationRect dstRect: Rect<Float>? = nil) throws(SDL_Error) -> Self {
    guard let texture = texture else { return self }
    
    let size = try texture.size(as: Float.self)
    
    var rect: SDL_FRect! = nil
    switch dstRect {
      case let dstRect?:
        rect = [
          dstRect.lowHalf.x, dstRect.lowHalf.y,
          dstRect.highHalf.x, dstRect.highHalf.y
        ]
      default:
        rect = [
          0, 0,
          size.x, size.y
        ]
    }
    
    return try self(SDL_RenderTexture, texture.pointer, nil, .some(&rect))
  }
  
  @discardableResult
  public func debug(text: String, position: Point<Float>, color fillColor: SDL_Color = .white, scale: Float = 1.0) throws(SDL_Error) -> Self {
    let color = try color.get()
    
    try self
      .set(color: fillColor)
      .set(scale: scale)
    
    guard SDL_RenderDebugText(pointer, position.x, position.y, text) else {
      throw SDL_Error.error
    }
    
    return try set(color: color)
  }
}
  
// MARK: - Sizing Functions
extension Renderer {
  @discardableResult
  public func outputSize<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: FixedWidthInteger {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetRenderOutputSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return [T(width), T(height)]
  }
  
  @discardableResult
  public func outputSize<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: BinaryFloatingPoint {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetRenderOutputSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return [T(width), T(height)]
  }
  
  @discardableResult
  public func set<T: SIMDScalar>(logicalSize size: Size<T>, presentation: SDL_RendererLogicalPresentation) throws(SDL_Error) -> Self where T: FixedWidthInteger {
    let sizeAsInt32 = size.to(Int32.self)
    let width = sizeAsInt32.x, height = sizeAsInt32.y
    guard case(.success) = self.resultOf(SDL_SetRenderLogicalPresentation, width, height, presentation) else {
      throw SDL_Error.error
    }
    return self
  }
  
  @discardableResult
  public func set<T: SIMDScalar>(logicalSize size: Size<T>, presentation: SDL_RendererLogicalPresentation) throws(SDL_Error) -> Self where T: BinaryFloatingPoint {
    let sizeAsInt32 = size.to(Int32.self)
    let width = sizeAsInt32.x, height = sizeAsInt32.y
    guard case(.success) = self.resultOf(SDL_SetRenderLogicalPresentation, width, height, presentation) else {
      throw SDL_Error.error
    }
    return self
  }
}
  
// MARK: - Fill Rects
extension Renderer {
  @discardableResult
  public func fill(rects: SDL_FRect..., color: SDL_Color) throws(SDL_Error) -> Self {
    try self.fill(rects: rects, color: color)
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
  public func set(scale: Float) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderScale, scale, scale)
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
