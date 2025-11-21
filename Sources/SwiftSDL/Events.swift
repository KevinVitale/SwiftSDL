extension SDL_Event {
  public var eventType: SDL_EventType {
    SDL_EventType(rawValue: type)!
  }
}

public func pollEvent() throws -> SDL_Event {
  var event = SDL_Event()
  while(SDL_PollEvent(&event)) {
    return event
  }
  return event
}

public func waitEvent() throws -> SDL_Event {
  var event = SDL_Event()
  if(SDL_WaitEvent(&event)) {
    return event
  }
  return event
}

extension SDL_KeyboardEvent {
  public static func == (lhs: Self, rhs: SDL_Keycode) -> Bool {
    lhs.key == rhs
  }
  
  public static func ~= (lhs: SDL_Keycode, rhs: Self) -> Bool {
    lhs == rhs.key
  }
}

extension SDL_MouseButtonEvent {
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: FixedWidthInteger {
    Point(x: Int32(x), y: Int32(y)).to(type)
  }
  
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint {
    Point(x: Float(x), y: Float(y)).to(type)
  }
}

extension SDL_MouseMotionEvent {
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: FixedWidthInteger {
    Point(x: Int32(x), y: Int32(y)).to(type)
  }
  
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint {
    Point(x: Float(x), y: Float(y)).to(type)
  }
  
  public func relative<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: FixedWidthInteger {
    Point(x: Int32(xrel), y: Int32(yrel)).to(type)
  }
  
  public func relative<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint {
    Point(x: Float(xrel), y: Float(yrel)).to(type)
  }
}

extension SDL_TouchFingerEvent {
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: FixedWidthInteger {
    Point(x: Int32(x), y: Int32(y)).to(type)
  }
  
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint {
    Point(x: Float(x), y: Float(y)).to(type)
  }
}
