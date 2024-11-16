public protocol SDLObjectProtocol: AnyObject {
  associatedtype Pointer: Hashable
  var pointer: Pointer { get }
}

/*
 Explore this
 https://github.com/swiftlang/swift/blob/main/docs/OptimizationTips.rst#advice-use-unmanaged-references-to-avoid-reference-counting-overhead
 */

public final class SDLObject<Pointer: Hashable>: SDLObjectProtocol {
  enum Tag {
    case custom(String)
  }
  
  public let pointer: Pointer
  
  private let destroy: (Pointer) -> Void
  private let tag: Tag
  
  required init(_ pointer: Pointer, tag: Tag, destroy: @escaping (Pointer) -> Void = { _ in }) {
    // print("\(type(of: Pointer.self)): \(#function), \(tag)")
    self.destroy = destroy
    self.pointer = pointer
    self.tag = tag
  }

  deinit {
    /*
    #if DEBUG
    print("\(type(of: Pointer.self)): \(#function), \(tag)")
    #endif
     */
    self.destroy(pointer)
  }
}

public func SDL_BufferPointer<Value>(_ allocate: (UnsafeMutablePointer<Int32>) -> UnsafeMutablePointer<Value>?) throws(SDL_Error) -> [Value] {
  var count: Int32 = 0
  guard let pointer = allocate(&count) else {
    throw SDL_Error.error
  }
  defer { SDL_free(pointer) }
  let bufferPtr = UnsafeMutableBufferPointer.init(start: pointer, count: Int(count))
  return Array(bufferPtr)
}

extension SDLObjectProtocol {
  @discardableResult
  @inlinable
  public func callAsFunction<Value, each Argument>(_ block: (Pointer, repeat each Argument) -> Value?, _ argument: repeat each Argument) throws(SDL_Error) -> Value {
    guard let value = block(pointer, repeat each argument) else {
      throw SDL_Error.error
    }
    return value
  }
  
  @discardableResult
  @inlinable
  public func callAsFunction<each Argument>(_ block: (Pointer, repeat each Argument) -> Bool, _ arguments: repeat each Argument) throws(SDL_Error) -> Self {
    guard block(pointer, repeat each arguments) else {
      throw SDL_Error.error
    }
    return self
  }
  
  @discardableResult
  @inlinable
  public func resultOf<Value, each Argument>(_ block: (Pointer, repeat each Argument) -> Value?, _ argument: repeat each Argument) -> Result<Value, SDL_Error> {
    guard let value = block(pointer, repeat each argument) else {
      return .failure(.error)
    }
    return .success(value)
  }
  
  @discardableResult
  @inlinable
  public func resultOf<each Argument>(_ block: (Pointer, repeat each Argument) -> Bool, _ argument: repeat each Argument) -> Result<Self, SDL_Error> {
    guard block(pointer, repeat each argument) else {
      return .failure(.error)
    }
    return .success(self)
  }
}
