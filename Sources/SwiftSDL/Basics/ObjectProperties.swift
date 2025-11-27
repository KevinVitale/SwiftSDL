public final class SDL_PropertiesID: Identifiable, Sendable {
  /// This is necessary to prevent a deadlock during `deinit`
  private static nonisolated(unsafe) var __global: ID?
  
  public let id: Uint32
  
  public init(id: ID? = nil, properties: [(String, (any SDL_PropertyTypeValue))]? = nil) throws(SDL_Error) {
    let id = id ?? SDL_CreateProperties()
    guard id != 0 else { throw .error }
    self.id = id
    
    // Assign default properties
    if let properties = properties {
      for (property, value) in properties {
        self[property] = value
      }
    }
  }
  
  public convenience init(id: ID? = nil, properties: (String, (any SDL_PropertyTypeValue))...) throws(SDL_Error) {
    try self.init(id: id, properties: properties)
  }
  
  deinit {
    /// Storing a static `__global` and comparing it prevents a deadlock.
    /// E.g., if this was a call to `SDL_GetGlobalProperties()` and
    /// the global properties was storing _any_ `SDL_Object`,
    /// a deadlock would occur.
    guard id != Self.__global else { return }
    unlock()
    SDL_DestroyProperties(id)
  }
  
  private func has(property: String) -> Bool {
    SDL_HasProperty(id, property)
  }
  
  private func propertyType(of property: String) -> SDL_PropertyType {
    __SDL_GetPropertyType(id, property)
  }
  
  public func lock() throws(SDL_Error) {
    guard SDL_LockProperties(id) else {
      throw .error
    }
  }
  
  public func unlock() {
    SDL_UnlockProperties(id)
  }
  
  /// - note: Setting `nil` removes the property from the receiver.
  public subscript(property: String) -> (any SDL_PropertyTypeValue)? {
    get {
      switch propertyType(of: property) {
        case .string: return try? String(property, on: self)
        case .number: return try? Int64(property, on: self)
        case .float: return try? Float(property, on: self)
        case .boolean: return try? Bool(property, on: self)
        case .pointer: return try? UnsafeMutableRawPointer(property, on: self)
        default: return nil
      }
    }
    set {
      guard let newValue = newValue else { return _ = SDL_ClearProperty(id, property) }
      try? newValue.set(property, on: self)
    }
  }
  
  public static func global() throws(SDL_Error) -> Self {
    /// Storing the _global properties ID_ in a static prevents deadlocking
    /// in certain edge-cases.
    if __global == nil {
      __global = __SDL_GetGlobalProperties()
    }
    return try Self(id: __global)
  }
}

public protocol SDL_PropertyTypeValue {
  associatedtype ValueType
  var wrappedValue: ValueType { get }
  
  func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error)
}

extension String: SDL_PropertyTypeValue {
  public var wrappedValue: Self { self }
  
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    SDL_SetStringProperty(properties.id, property, wrappedValue)
  }
  
  fileprivate init(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    let cString = SDL_GetStringProperty(properties.id, property, "")!
    self = String(cString: cString)
  }
}

extension Int64: SDL_PropertyTypeValue {
  public var wrappedValue: Self { self }
  
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    SDL_SetNumberProperty(properties.id, property, Sint64(wrappedValue))
  }
  
  fileprivate init(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    self = Self(SDL_GetNumberProperty(properties.id, property, .min))
  }
}

extension UInt32: SDL_PropertyTypeValue {
  public var wrappedValue: Self { self }
  
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    SDL_SetNumberProperty(properties.id, property, Sint64(wrappedValue))
  }
  
  fileprivate init(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    self = Self(SDL_GetNumberProperty(properties.id, property, .min))
  }
}

extension Float: SDL_PropertyTypeValue {
  public var wrappedValue: Self { self }
  
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    SDL_SetFloatProperty(properties.id, property, Float(wrappedValue))
  }
  
  fileprivate init(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    self = SDL_GetFloatProperty(properties.id, property, .nan)
  }
}

extension Double: SDL_PropertyTypeValue {
  public var wrappedValue: Float { Float(self) }
  
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    SDL_SetFloatProperty(properties.id, property, Float(wrappedValue))
  }
  
  fileprivate init(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    self = Double(SDL_GetFloatProperty(properties.id, property, .nan))
  }
}

extension Bool: SDL_PropertyTypeValue {
  public var wrappedValue: Self { self }
  
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    SDL_SetBooleanProperty(properties.id, property, wrappedValue)
  }
  
  fileprivate init(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    self = SDL_GetBooleanProperty(properties.id, property, false)
  }
}

extension UnsafeMutableRawPointer: SDL_PropertyTypeValue {
  public var wrappedValue: Self { self }
  
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    SDL_SetPointerProperty(properties.id, property, self)
  }
  
  fileprivate init(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    self = SDL_GetPointerProperty(properties.id, property, nil)
  }
}

extension Optional<UnsafeMutableRawPointer>: SDL_PropertyTypeValue {
  public var wrappedValue: Self { self }
  
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    SDL_SetPointerProperty(properties.id, property, self)
  }
  
  fileprivate init(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    self = SDL_GetPointerProperty(properties.id, property, nil)
  }
}

extension SDL_Object: SDL_PropertyTypeValue { }

extension SDL_PropertyTypeValue where Self: AnyObject, ValueType == UnsafeMutableRawPointer {
  /**
   A weak pointer reference to this object.
   
   - returns: An unsafe, unretained pointer to this object.
   */
  public var wrappedValue: ValueType {
    Unmanaged.passUnretained(self).toOpaque()
  }
  
  /**
   Stores a retained reference into `properties`.
   Releases the retained value automatically when the value is removed from `properties.`
   */
  public func set(_ property: String, on properties: SDL_PropertiesID) throws(SDL_Error) {
    let pointer = Unmanaged.passRetained(self).toOpaque()
    SDL_SetPointerPropertyWithCleanup(
      properties.id,
      property,
      pointer,
      { userdate, value in
        _ = Unmanaged<AnyObject>.fromOpaque(value!).takeRetainedValue() as AnyObject
      },
      nil
    )
  }
}

extension Result where Success == SDL_PropertiesID, Failure == SDL_Error {
  public subscript(property: String) -> Result<(any SDL_PropertyTypeValue)?, Failure> {
    map { $0[property] }
  }
}

extension SDL_PropertyType: @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .boolean: return "boolean"
      case .float: return "float"
      case .number: return "number"
      case .pointer: return "pointer"
      case .string: return "string"
      default: return "invalid"
    }
  }
}

extension SDL_PropertiesID: CustomDebugStringConvertible {
  private struct EnumerateUserData {
    fileprivate var count: Int = 0
    fileprivate var pointer: UnsafeMutablePointer<(String, any SDL_PropertyTypeValue)>? = nil
    
    fileprivate var properties: [String : any SDL_PropertyTypeValue] {
      guard let pointer = pointer else { return [:] }
      let propertiesAsArray = Array<(String, any SDL_PropertyTypeValue)>(UnsafeBufferPointer(start: pointer, count: count))
      return Dictionary<String, any SDL_PropertyTypeValue>.init(propertiesAsArray) {
        $1
      }
    }
  }
  
  fileprivate func dictionaryRepresentation() throws(SDL_Error) -> [String : any SDL_PropertyTypeValue] {
    let callback: __SDL_EnumeratePropertiesCallback = { userdata, propertyID, name in
      let state = userdata?.bindMemory(to: EnumerateUserData.self, capacity: 1).pointee
      
      if let name = name, var state = state {
        state.count += 1
        if state.pointer == nil {
          state.pointer = .allocate(capacity: state.count)
        }
        else {
          let pointer = state.pointer
          state.pointer = .allocate(capacity: state.count)
          state.pointer?.moveInitialize(from: pointer!, count: state.count)
        }
        
        let name = String(cString: name)
        let propertyType = __SDL_GetPropertyType(propertyID, name)
        switch propertyType {
          case .boolean:
            let bool = SDL_GetBooleanProperty(propertyID, name, false)
            (state.pointer! + state.count - 1).initialize(to: (name, bool))
          case .float:
            let float = SDL_GetFloatProperty(propertyID, name, 0)
            (state.pointer! + state.count - 1).initialize(to: (name, float))
          case .number:
            let number = SDL_GetNumberProperty(propertyID, name, 0)
            (state.pointer! + state.count - 1).initialize(to: (name, number))
          case .pointer:
            let pointer = SDL_GetPointerProperty(propertyID, name, nil)
            (state.pointer! + state.count - 1).initialize(to: (name, pointer))
          case .string:
            if let cString = SDL_GetStringProperty(propertyID, name, "") {
              (state.pointer! + state.count - 1).initialize(to: (name, String(cString: cString)))
            }
          default: ()
        }
        
        userdata?.moveInitializeMemory(as: EnumerateUserData.self, from: &state, count: 1)
      }
    }
    
    var userdata = EnumerateUserData()
    guard SDL_EnumerateProperties(id, callback, &userdata) else {
      throw .error
    }
    
    return userdata.properties
  }
  
  public var debugDescription: String {
    (try? dictionaryRepresentation().debugDescription) ?? ""
  }
}
