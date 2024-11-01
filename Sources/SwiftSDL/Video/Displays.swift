public enum Displays {
  public static var connected: Result<[DisplayID], SDL_Error> {
    var deviceCount: Int32 = 0
    guard let devicePtr = SDL_GetDisplays(&deviceCount) else {
      return .failure(.error)
    }
    defer { SDL_free(devicePtr) }
    
    var devices = [DisplayID](repeating: .invalid, count: Int(deviceCount))
    for index in 0..<Int(deviceCount) {
      devices[index] = .connected(devicePtr[index])
    }
    
    return .success(devices)
  }
  
  public static var primary: Result<DisplayID, SDL_Error> {
    let displayID = SDL_GetPrimaryDisplay()
    guard displayID != 0 else {
      return .failure(.error)
    }
    return .success(.connected(displayID))
  }
}

public enum DisplayID: Decodable, CustomDebugStringConvertible {
  case connected(SDL_DisplayID)
  case invalid
  
  public var id: SDL_DisplayID {
    switch self {
      case .connected(let displayID): return displayID
      case .invalid: return .zero
    }
  }
  
  public var name: Result<String, SDL_Error> {
    guard let name = SDL_GetDisplayName(id) else {
      return .failure(.error)
    }
    return .success(String(cString: name))
  }
  
  public var contentScale: Result<Float, SDL_Error> {
    let contentScale = SDL_GetDisplayContentScale(id)
    guard contentScale > 0 else {
      return .failure(.error)
    }
    return .success(contentScale)
  }
  
  public var debugDescription: String {
    ""
  }
}
