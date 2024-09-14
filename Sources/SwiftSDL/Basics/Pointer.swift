public protocol SDLPointer {
  associatedtype Value: Hashable
  static func destroy(_ pointee: Value)
}

public protocol SDLObjectProtocol {
  associatedtype Pointer: SDLPointer
  var pointer: Pointer.Value { get }
}

extension SDLObjectProtocol {
  public func destroy() {
    print("\(type(of: Pointer.self)): \(#function)")
    Pointer.destroy(pointer)
  }
}

public final class SDLObject<Pointer: SDLPointer>: SDLObjectProtocol {
  public init (pointer: Pointer.Value) {
    self.pointer = pointer
  }
  
  public let pointer: Pointer.Value
}

extension SDLObjectProtocol {
  @discardableResult
  public func get<Value, each Argument>(_ block: (Pointer.Value, repeat each Argument) -> Value?, _ argument: repeat each Argument) throws(SDL_Error) -> Value {
    guard let value = block(pointer, repeat each argument) else {
      throw SDL_Error.error
    }
    return value
  }
  
  @discardableResult
  @MainActor
  public func set<each Argument>(_ block: (Pointer.Value, repeat each Argument) -> Bool, _ arguments: repeat each Argument) throws(SDL_Error) -> Self {
    guard block(pointer, repeat each arguments) else {
      throw SDL_Error.error
    }
    return self
  }
  
  @discardableResult
  public func resultOf<Value, each Argument>(_ block: (Pointer.Value, repeat each Argument) -> Value?, _ argument: repeat each Argument) -> Result<Value, SDL_Error> {
    guard let value = block(pointer, repeat each argument) else {
      return .failure(.error)
    }
    return .success(value)
  }
  
  @discardableResult
  public func resultOf<each Argument>(_ block: (Pointer.Value, repeat each Argument) -> Bool, _ argument: repeat each Argument) -> Result<Self, SDL_Error> {
    guard block(pointer, repeat each argument) else {
      return .failure(.error)
    }
    return .success(self)
  }
}
