extension SDL_PropertiesID {
  private struct EnumerateUserData {
    var count: Int = 0
    var pointer: UnsafeMutablePointer<(String, any PropertyValue)>? = nil
    
    var properties: [(String, any PropertyValue)] {
      guard let pointer = pointer else {
        return []
      }
      return Array(UnsafeBufferPointer(start: pointer, count: count))
    }
  }
  
  public static func global() throws(SDL_Error) -> Self {
    let global = SDL_GetGlobalProperties()
    guard global != .zero else {
      throw SDL_Error.error
    }
    return global
  }
  
  public func enumerated() throws(SDL_Error) -> EnumeratedSequence<[(String, any PropertyValue)]> {
    let callback: SDL_EnumeratePropertiesCallback = { userdata, propertyID, name in
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
        switch propertyID.type(of: name) {
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
    guard SDL_EnumerateProperties(self, callback, &userdata) else {
      throw SDL_Error.error
    }
    
    return userdata.properties.enumerated()
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
