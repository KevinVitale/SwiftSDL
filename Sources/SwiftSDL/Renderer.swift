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
