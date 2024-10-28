public typealias Rect<Scalar: SIMDScalar> = SIMD4<Scalar>
public typealias Point<Scalar: SIMDScalar> = SIMD2<Scalar>
public typealias Size<Scalar: SIMDScalar> = SIMD2<Scalar>

public typealias SDL_Size = SDL_Point
public typealias SDL_FSize = SDL_FPoint

extension SDL_Rect: @retroactive SIMD {
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
  
  public func to<S: SIMDScalar>(_ type: S.Type) -> SDL_FRect where S: BinaryFloatingPoint, Scalar: FixedWidthInteger {
    var s = SIMD4<Float>()
    for i in indices {
      s[i] = Float(self[i])
    }
    return SDL_FRect(x: s[0], y: s[1], w: s[2], h: s[3])
  }
}

extension SDL_FRect: @retroactive SIMD {
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
  
  public func to<S: SIMDScalar>(_ type: S.Type) -> SDL_Rect where S: FixedWidthInteger, Scalar: BinaryFloatingPoint {
    var s = SIMD4<Int32>()
    for i in indices {
      s[i] = Int32(self[i])
    }
    return SDL_Rect(x: s[0], y: s[1], w: s[2], h: s[3])
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

extension SIMD4 {
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

