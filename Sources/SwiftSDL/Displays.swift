extension Game {
  public var displays: Result<[SDL_DisplayID], SDL_Error> {
    Result {
      try SDL_BufferPointer(SDL_GetDisplays)
        .map({ .connected($0) })
    }
    .mapError({
      $0 as! SDL_Error
    })
  }
  
  public var primaryDisplay: Result<SDL_DisplayID, SDL_Error> {
    let displayID = SDL_GetPrimaryDisplay()
    guard displayID != 0 else {
      return .failure(.error)
    }
    return .success(.connected(displayID))
  }
}

public enum SDL_DisplayID: Decodable, CustomDebugStringConvertible {
  case connected(UInt32)
  case invalid
  
  public var id: UInt32 {
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
  
  // Information on SDL3 window size:
  // https://github.com/libsdl-org/SDL/blob/main/docs/README-highdpi.md
  /// Retrieves the suggested amplification factor when drawing in native coordinates.
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
