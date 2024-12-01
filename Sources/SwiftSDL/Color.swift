extension SDL_Color {
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
