public final class SDL_PropertiesID: Identifiable, Sendable {
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
    guard id != SDL_GetGlobalProperties() else { return }
    unlock()
    SDL_DestroyProperties(id)
  }
  
  private func has(property: String) -> Bool {
    SDL_HasProperty(id, property)
  }
  
  private func propertyType(of property: String) -> SDL_PropertyType {
    SDL_GetPropertyType(id, property)
  }
  
  public func lock() throws(SDL_Error) {
    guard SDL_LockProperties(id) else {
      throw .error
    }
  }
  
  public func unlock() {
    SDL_UnlockProperties(id)
  }
  
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
      guard let newValue = newValue, !has(property: property) else {
        return _ = SDL_ClearProperty(id, property)
      }
      try? newValue.set(property, on: self)
    }
  }
  
  public static func global() throws(SDL_Error) -> Self {
    try Self(id: SDL_GetGlobalProperties())
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
  public var wrappedValue: ValueType {
    Unmanaged.passUnretained(self).toOpaque()
  }
  
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
