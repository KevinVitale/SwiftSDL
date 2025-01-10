public protocol SDLObjectProtocol: AnyObject {
  associatedtype Pointer: Hashable
  var pointer: Pointer { get }
}

public final class SDLObject<Pointer: Hashable>: SDLObjectProtocol, @unchecked Sendable {
  /// Used for associating a tag with an SDLObject instance, primarily for debugging and memory-allocation tracking.
  @available(*, deprecated, message: "Will be removed in a future release")
  public enum Tag {
    /// A user-defined string for debugging purposes.
    case custom(String)
    
    /// A default, no-tag state.
    case empty
  }
  
  /// The underlying resource reference managed by this object.
  public let pointer: Pointer
  
  /// A callback invoked during deinitialization to clean up the resource.
  private let destroy: (Pointer) -> Void
  
  /// A debugging or tracking tag for the instance.
  private let tag: Tag
  
  
  /// Creates an instance of an SDL object from an underlying pointer reference.
  /// - Parameters:
  ///   - pointer: The resource pointer being managed.
  ///   - tag: A debugging or memory-allocation tag (default: .empty).
  ///   - destroy: A closure invoked during deinitialization to clean up the resource (default: a no-op closure).
  public required init(_ pointer: Pointer, tag: Tag = .empty, destroy: @escaping (Pointer) -> Void = { _ in }) {
    // print("\(type(of: Pointer.self)): \(#function), \(tag)")
    self.destroy = destroy
    self.pointer = pointer
    self.tag = tag
  }

  /// Ensures the destroy callback is called with the managed pointer when the SDLObject instance is deallocated.
  deinit {
    /*
    #if DEBUG
    print("\(type(of: Pointer.self)): \(#function), \(tag)")
    #endif
     */
    self.destroy(pointer)
  }
}

extension SDLObjectProtocol {
  @discardableResult
  @inlinable
  public func callAsFunction<Value, each Argument>(_ block: (Pointer, repeat each Argument) -> Value?, _ argument: repeat each Argument) throws(SDL_Error) -> Value {
    guard let value = block(pointer, repeat each argument) else {
      throw .error
    }
    return value
  }
  
  @discardableResult
  @inlinable
  public func callAsFunction<each Argument>(_ block: (Pointer, repeat each Argument) -> Bool, _ arguments: repeat each Argument) throws(SDL_Error) -> Self {
    guard block(pointer, repeat each arguments) else {
      throw .error
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

/**
 This function facilitates the allocation and conversion of a buffer pointer
 to an array of values, handling resource cleanup and error management seamlessly.
 
 **Example:**
 
 ```
 let joysticks = try SDL_BufferPointer(SDL_GetJoysticks)
 ```
 
 The closure is responsible for:
 - Modifying the Int32 pointer to indicate the number of elements allocated.
 - Returning a pointer to the allocated buffer or nil on failure.
 
 - parameter allocate: A closure that takes an `UnsafeMutablePointer<Int32>` and returns an optional `UnsafeMutablePointer<Value>`.
 - returns: A Swift array containing the elements of the allocated buffer.
 - throws: Throw `SDL_Error.error` when the allocate closure fails to return a valid pointer.
 */
public func SDL_BufferPointer<Value>(_ allocate: (UnsafeMutablePointer<Int32>) -> UnsafeMutablePointer<Value>?) throws(SDL_Error) -> [Value] {
  var count: Int32 = 0
  guard let pointer = allocate(&count) else {
    throw .error
  }
  defer { SDL_free(pointer) }
  let bufferPtr = UnsafeMutableBufferPointer.init(start: pointer, count: Int(count))
  return Array(bufferPtr)
}
