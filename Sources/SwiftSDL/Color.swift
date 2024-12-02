extension SDL_Color: @retroactive Codable {
  public init(from decoder: any Decoder) throws {
    let decoder = try decoder.singleValueContainer()
    let color = try decoder.decode(UInt32.self)
    let red   = UInt8(truncatingIfNeeded: color >> 24)
    let green = UInt8(truncatingIfNeeded: color >> 16)
    let blue  = UInt8(truncatingIfNeeded: color >> 8)
    let alpha = UInt8(truncatingIfNeeded: color >> 0)
    self = .init(r: red, g: green, b: blue, a: alpha)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var encoder = encoder.singleValueContainer()
    var color = UInt32.zero
    color += UInt32(r) << 24
    color += UInt32(g) << 16
    color += UInt32(b) << 8
    color += UInt32(a)
    try encoder.encode(color)
  }
  
  @inlinable
  public static var clear: Self { .init(r: 0, g: 0, b: 0, a: 0) }
  
  @inlinable
  public static var black: Self { .init(r: 0, g: 0, b: 0, a: 255) }
  
  @inlinable
  public static var white: Self { .init(r: 255, g: 255, b: 255, a: 255) }
  
  @inlinable
  public static var gray: Self { .init(r: 127, g: 127, b: 127, a: 255) }
  
  @inlinable
  public static var red: Self { .init(r: 255, g: 0, b: 0, a: 255) }
  
  @inlinable
  public static var green: Self { .init(r: 0, g: 255, b: 0, a: 255) }
  
  @inlinable
  public static var blue: Self { .init(r: 0, g: 0, b: 255, a: 255) }
  
  @inlinable
  public static var yellow: Self { .init(r: 255, g: 255, b: 0, a: 255) }
  
  @inlinable
  public static var purple: Self { .init(r: 255, g: 0, b: 255, a: 255) }
  
  @inlinable
  public static var random: Self {
    .init(
      r: .random(in: 0..<255),
      g: .random(in: 0..<255),
      b: .random(in: 0..<255),
      a: 255
    )
  }
}
