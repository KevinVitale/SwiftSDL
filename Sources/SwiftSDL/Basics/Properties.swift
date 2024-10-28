extension SDL_PropertiesID {
  public static var global: Self {
    SDL_GetGlobalProperties()
  }
  
  /* PropertyValue */
  @discardableResult
  public func set<P: PropertyValue>(_ property: String, value: P) -> Bool {
    switch value.self {
      case let value as String: return SDL_SetStringProperty(self, property, value)
      case let value as Float: return SDL_SetFloatProperty(self, property, value)
      case let value as Bool: return SDL_SetBooleanProperty(self, property, value)
      case let value as Sint64: return SDL_SetNumberProperty(self, property, value)
      case let value as Optional<UnsafeMutableRawPointer>: return SDL_SetPointerProperty(self, property, value)
      default: return false
    }
  }

  @discardableResult
  public func clear(_ property: String) -> Bool {
    SDL_ClearProperty(self, property)
  }
  
  public func destroy() {
    SDL_DestroyProperties(self)
  }
  
  public func has(_ property: String) -> Bool {
    SDL_HasProperty(self, property)
  }
  
  public func type(of property: String) -> SDL_PropertyType {
    SDL_GetPropertyType(self, property)
  }
  
  @discardableResult
  public func lock() -> Bool {
    SDL_LockProperties(self)
  }
  
  public func unlock() {
    SDL_UnlockProperties(self)
  }
}

public protocol PropertyValue {
  associatedtype ValueType
  var value: ValueType { get }
}

extension String: PropertyValue { public var value: Self { self } }
extension Bool: PropertyValue { public var value: Self { self } }
extension Sint64: PropertyValue { public var value: Self { self } }
extension Float: PropertyValue { public var value: Self { self } }
extension Double: PropertyValue { public var value: Float { Float(self) } }
extension Optional<UnsafeMutableRawPointer>: PropertyValue { public var value: Self { self } }

extension SDL_PropertyType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let invalid = SDL_PROPERTY_TYPE_INVALID
  public static let pointer = SDL_PROPERTY_TYPE_POINTER
  public static let string = SDL_PROPERTY_TYPE_STRING
  public static let number = SDL_PROPERTY_TYPE_NUMBER
  public static let float = SDL_PROPERTY_TYPE_FLOAT
  public static let boolean = SDL_PROPERTY_TYPE_BOOLEAN
  
  public var debugDescription: String {
    switch self {
      case .invalid: return "invalid"
      case .pointer: return "pointer"
      case .string: return "string"
      case .boolean: return "boolean"
      case .float: return "float"
      case .number: return "number"
      default: return Self.invalid.debugDescription
    }
  }
  
  public static var allCases: [SDL_PropertyType] {
    [
      .invalid,
      .pointer,
      .string,
      .number,
      .float,
      .boolean
    ]
  }
}
