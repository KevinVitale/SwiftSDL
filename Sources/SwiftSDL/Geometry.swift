public typealias Rect<Scalar: SIMDScalar> = SIMD4<Scalar>
public typealias Point<Scalar: SIMDScalar> = SIMD2<Scalar>
public typealias Size<Scalar: SIMDScalar> = SIMD2<Scalar>

public typealias SDL_Size = SDL_Point
public typealias SDL_FSize = SDL_FPoint

extension SDL_Point: @retroactive SIMD {
  public init<S: SIMDScalar & FixedWidthInteger>(_ point: SIMD2<S>) {
    let simd = point.to(Int32.self)
    self = SDL_Point(x: simd[0], y: simd[1])
  }

  public subscript(index: Int) -> SIMD2<Int32>.Scalar {
    get {
      switch index {
        case 0: return x
        case 1: return y
        default: fatalError()
      }
    }
    set(newValue) {
      switch index {
        case 0: x = newValue
        case 1: y = newValue
        default: ()
      }
    }
  }
  
  public var scalarCount: Int {
    SIMD2<Int32>.scalarCount
  }
  
  public typealias MaskStorage = SIMD2<Int32>.MaskStorage
  public typealias Scalar = SIMD2<Int32>.Scalar
  
  @discardableResult
  @inlinable
  public func callAsFunction<Value, each Argument>(_ block: (UnsafePointer<Self>?, repeat each Argument) -> Value, _ argument: repeat each Argument) -> Value {
    var this = self
    return block(&this, repeat each argument)
  }
  
  public func to<S: SIMDScalar & BinaryFloatingPoint>(_ type: S.Type) -> SIMD2<S> where Scalar: FixedWidthInteger {
    var s = SIMD2<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }

  public func to<S: SIMDScalar & BinaryFloatingPoint>(_ type: S.Type) -> SDL_FPoint where Scalar: FixedWidthInteger {
    SDL_FPoint(self.to(S.self))
  }
}

extension SDL_FPoint: @retroactive SIMD {
  public init<S: SIMDScalar & BinaryFloatingPoint>(_ point: SIMD2<S>) {
    let simd = point.to(Float.self)
    self = SDL_FPoint(x: simd[0], y: simd[1])
  }
  
  public subscript(index: Int) -> SIMD2<Float>.Scalar {
    get {
      switch index {
        case 0: return x
        case 1: return y
        default: fatalError()
      }
    }
    set(newValue) {
      switch index {
        case 0: x = newValue
        case 1: y = newValue
        default: ()
      }
    }
  }
  
  public var scalarCount: Int {
    SIMD2<Float>.scalarCount
  }
  
  public typealias MaskStorage = SIMD2<Float>.MaskStorage
  public typealias Scalar = SIMD2<Float>.Scalar
  
  @discardableResult
  @inlinable
  public func callAsFunction<Value, each Argument>(_ block: (UnsafePointer<Self>?, repeat each Argument) -> Value, _ argument: repeat each Argument) -> Value {
    var this = self
    return block(&this, repeat each argument)
  }
}


extension SDL_Rect: @retroactive SIMD {
  public init<S: SIMDScalar & FixedWidthInteger>(_ rect: SIMD4<S>) {
    let simd = rect.to(Int32.self)
    self = SDL_Rect(x: simd[0], y: simd[1], w: simd[2], h: simd[3])
  }

  public subscript(index: Int) -> SIMD4<Int32>.Scalar {
    get {
      switch index {
        case 0: return x
        case 1: return y
        case 2: return w
        case 3: return h
        default: fatalError()
      }
    }
    set(newValue) {
      switch index {
        case 0: x = newValue
        case 1: y = newValue
        case 2: w = newValue
        case 3: h = newValue
        default: ()
      }
    }
  }
  
  public var scalarCount: Int {
    SIMD4<Int32>.scalarCount
  }
  
  public typealias MaskStorage = SIMD4<Int32>.MaskStorage
  public typealias Scalar = SIMD4<Int32>.Scalar
  
  public var topLeft     : SDL_Point { [self[0], self[1]] }
  public var topRight    : SDL_Point { [self[2], self[0]] }
  public var bottomLeft  : SDL_Point { [self[0], self[3]] }
  public var bottomRight : SDL_Point { [self[2], self[3]] }

  @discardableResult
  @inlinable
  public func callAsFunction<Value, each Argument>(_ block: (UnsafePointer<Self>?, repeat each Argument) -> Value, _ argument: repeat each Argument) -> Value {
    var this = self
    return block(&this, repeat each argument)
  }
}

extension SDL_FRect: @retroactive SIMD {
  public init<S: SIMDScalar & BinaryFloatingPoint>(_ rect: SIMD4<S>) {
    let simd = rect.to(Float.self)
    self = SDL_FRect(x: simd[0], y: simd[1], w: simd[2], h: simd[3])
  }

  public subscript(index: Int) -> SIMD4<Float>.Scalar {
    get {
      switch index {
        case 0: return x
        case 1: return y
        case 2: return w
        case 3: return h
        default: fatalError()
      }
    }
    set(newValue) {
      switch index {
        case 0: x = newValue
        case 1: y = newValue
        case 2: w = newValue
        case 3: h = newValue
        default: ()
      }
    }
  }
  
  public var scalarCount: Int {
    SIMD4<Float>.scalarCount
  }
  
  public typealias MaskStorage = SIMD4<Float>.MaskStorage
  public typealias Scalar = SIMD4<Float>.Scalar
  
  public var topLeft     : SDL_FPoint { [self[0], self[1]] }
  public var topRight    : SDL_FPoint { [self[2], self[0]] }
  public var bottomLeft  : SDL_FPoint { [self[0], self[3]] }
  public var bottomRight : SDL_FPoint { [self[2], self[3]] }

  @discardableResult
  @inlinable
  public func callAsFunction<Value, each Argument>(_ block: (UnsafePointer<Self>?, repeat each Argument) -> Value, _ argument: repeat each Argument) -> Value {
    var this = self
    return block(&this, repeat each argument)
  }
  
  public func to<S: SIMDScalar & FixedWidthInteger>(_ type: S.Type) -> Rect<S> where Scalar: BinaryFloatingPoint {
    var s = SIMD4<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
    
  public func to<S: SIMDScalar & FixedWidthInteger>(_ type: S.Type) -> SDL_Rect where Scalar: BinaryFloatingPoint {
    SDL_Rect(self.to(S.self))
  }
}

extension SIMD2 {
  public func to<S: SIMDScalar>(_ type: S.Type) -> SIMD2<S> where S: FixedWidthInteger, Scalar: FixedWidthInteger {
    var s = SIMD2<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
  
  public func to<S: SIMDScalar>(_ type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint, Scalar: BinaryFloatingPoint {
    var s = SIMD2<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
  
  public func to<S: SIMDScalar>(_ type: S.Type) -> SIMD2<S> where S: FixedWidthInteger, Scalar: BinaryFloatingPoint {
    var s = SIMD2<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
  
  public func to<S: SIMDScalar>(_ type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint, Scalar: FixedWidthInteger {
    var s = SIMD2<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
}

extension SIMD2 where Scalar: FixedWidthInteger {
  public func callAsFunction(as type: SDL_Point.Type) -> SDL_Point {
    SDL_Size(self)
  }
}

extension SIMD2 where Scalar: BinaryFloatingPoint {
  public func callAsFunction(as type: SDL_FPoint.Type) -> SDL_FPoint {
    SDL_FSize(self)
  }
}

extension SIMD4 {
  public var topLeft     : SIMD2<Scalar> { [self[0], self[1]] }
  public var topRight    : SIMD2<Scalar> { [self[2], self[0]] }
  public var bottomLeft  : SIMD2<Scalar> { [self[0], self[3]] }
  public var bottomRight : SIMD2<Scalar> { [self[2], self[3]] }

  public func to<S: SIMDScalar>(_ type: S.Type) -> SIMD4<S> where S: FixedWidthInteger, Scalar: FixedWidthInteger {
    var s = SIMD4<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
  
  public func to<S: SIMDScalar>(_ type: S.Type) -> SIMD4<S> where S: BinaryFloatingPoint, Scalar: BinaryFloatingPoint {
    var s = SIMD4<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
  
  public func to<S: SIMDScalar>(_ type: S.Type) -> SIMD4<S> where S: FixedWidthInteger, Scalar: BinaryFloatingPoint {
    var s = SIMD4<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
  
  public func to<S: SIMDScalar>(_ type: S.Type) -> SIMD4<S> where S: BinaryFloatingPoint, Scalar: FixedWidthInteger {
    var s = SIMD4<S>()
    for i in indices {
      s[i] = S(self[i])
    }
    return s
  }
}

extension SIMD4 where Scalar: FixedWidthInteger {
  public func callAsFunction(as type: SDL_Rect.Type) -> SDL_Rect {
    SDL_Rect(self)
  }
}

extension SIMD4 where Scalar: BinaryFloatingPoint {
  public func callAsFunction(as type: SDL_FRect.Type) -> SDL_FRect {
    SDL_FRect(self)
  }
}

