public protocol SDL_ObjectProtocol: AnyObject {
  associatedtype Pointer: Hashable
  var pointer: Pointer { get }
  var userData: SDL_PropertiesID? { get }
}

extension String {
  fileprivate static let __SDL_ObjectUserDataTagKey = "SDL_Object.userData.key.tag"
}

public final class SDL_Object<Pointer: Hashable>: SDL_ObjectProtocol, @unchecked Sendable {
  /// The underlying resource reference managed by this object.
  public let pointer: Pointer
  
  /// A callback invoked during deinitialization to clean up the resource.
  private let destroy: (Pointer) -> Void
  
  /// A debugging or tracking tag for the instance.
  private var tag: String {
    (userData?[.__SDL_ObjectUserDataTagKey] as? String) ?? ""
  }
  
  /// Custom, user-defined properties. Created during _initialization_ (otherwise `nil`), and modifiable using String-based `subscript` setters.
  ///
  /// - warning: A `userData` reference is unique to, and owned by, the `SDL_Object` instance which created it during _initialization_.
  /// Meaning, any `SDL_Object` which share the same `pointer` value do not share the same `userData` object.
  public private(set) var userData: SDL_PropertiesID?
  
  /// Creates an instance of an SDL object from an underlying pointer reference.
  ///
  /// - Parameters:
  ///   - pointer: The resource pointer being managed.
  ///   - userData: Custom, user-defined runtime properties. An empty array can be passed in to force-create a set of properties.
  ///   - tag: A debugging or memory-allocation tag (default: .empty).
  ///   - destroy: A closure invoked during deinitialization to clean up the resource (default: a no-op closure).
  ///
  public required init(_ pointer: Pointer, userData: [(String, (any SDL_PropertyTypeValue))]? = nil, destroy: @escaping (Pointer) -> Void = { _ in }) {
    self.destroy = destroy
    self.pointer = pointer
    
    if let userData = userData {
      self.userData = try? .init(properties: userData)
    }
    else {
      self.userData = nil
    }
    
    /*
    if Pointer.self is OpaquePointer.Type {
      debugPrint("\(type(of: self)): \(#function), \(tag)")
    }
     */
  }
  
  public convenience init(_ pointer: Pointer, tag: String, destroy: @escaping (Pointer) -> Void = { _ in }) {
    self.init(pointer, userData: [(.__SDL_ObjectUserDataTagKey, tag)], destroy: destroy)
  }
  
  /// Get / set a custom, user-defined property.
  public subscript(property: String) -> (any SDL_PropertyTypeValue)? {
    get { self.userData?[property] }
    set { self.userData?[property] = newValue }
  }

  /// Ensures the destroy callback is called with the managed pointer when the SDLObject instance is deallocated.
  deinit {
    /*
    if Pointer.self is OpaquePointer.Type {
      debugPrint("(\(type(of: self))::\(#function)) — Destroying object: (typeOf: \(type(of: pointer))) (properties: \(tag))")
    }
     */
    self.destroy(pointer)
  }
}

extension Result where Success: SDL_ObjectProtocol, Failure == SDL_Error {
}

extension SDL_ObjectProtocol {
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
