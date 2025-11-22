public protocol SDL_ObjectProtocol: AnyObject {
  associatedtype Pointer: Hashable
  var pointer: Pointer { get }
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
    (userData[.__SDL_ObjectUserDataTagKey] as? String) ?? ""
  }
  
  private let userData: SDL_PropertiesID = try! .init()
  
  /// Creates an instance of an SDL object from an underlying pointer reference.
  /// - Parameters:
  ///   - pointer: The resource pointer being managed.
  ///   - tag: A debugging or memory-allocation tag (default: .empty).
  ///   - destroy: A closure invoked during deinitialization to clean up the resource (default: a no-op closure).
  public required init(_ pointer: Pointer, userData: [(String, (any SDL_PropertyTypeValue))]? = nil, destroy: @escaping (Pointer) -> Void = { _ in }) {
    self.destroy = destroy
    self.pointer = pointer
    
    for (property, value) in userData ?? [] {
      self.userData[property] = value
    }
    
    debugPrint("\(type(of: Pointer.self)): \(#function), \(tag)")
  }
  
  public convenience init(_ pointer: Pointer, tag: String, destroy: @escaping (Pointer) -> Void = { _ in }) {
    self.init(pointer, userData: [(.__SDL_ObjectUserDataTagKey, tag)], destroy: destroy)
  }
  
  public subscript(property: String) -> (any SDL_PropertyTypeValue)? {
    get { self.userData[property] }
    set { self.userData[property] = newValue }
  }

  /// Ensures the destroy callback is called with the managed pointer when the SDLObject instance is deallocated.
  deinit {
    debugPrint("(\(type(of: self))::\(#function)) — Destroying object: \(type(of: pointer)) \(tag)")
    self.destroy(pointer)
  }
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
