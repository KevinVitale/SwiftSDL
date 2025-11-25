extension GameLoop {
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
  
  public var bounds: Result<SDL_Rect, SDL_Error> {
    var rect: SDL_Rect = .zero
    guard __SDL_GetDisplayBounds(id, &rect) else {
      return .failure(.error)
    }
    return .success(rect)
  }
  
  public var usableBounds: Result<SDL_Rect, SDL_Error> {
    var rect: SDL_Rect = .zero
    guard __SDL_GetDisplayUsableBounds(id, &rect) else {
      return .failure(.error)
    }
    return .success(rect)
  }
  
  public var contentScale: Result<Float, SDL_Error> {
    let contentScale = __SDL_GetDisplayContentScale(id)
    guard contentScale != .zero else { return .failure(.error) }
    return .success(contentScale)
  }
  
  public var fullscreenDisplayModes: Result<[SDL_DisplayMode], SDL_Error> {
    Result { try SDL_BufferPointerWithID(id: id, __SDL_GetFullscreenDisplayModes) }
    .mapError { $0 as! SDL_Error }
  }

  /**
   Is `true` if the display has HDR headroom above the SDR white point.
   - note: This is for informational and diagnostic purposes only, as not all platforms provide this information at the display level.
   */
  public var isHDREnabled: Bool {
    (try? self.properties[SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN].get()?.wrappedValue as? Bool) ?? false
  }
  
  /**
   The _"panel orientation"_ property for the display in degrees of clockwise rotation.
   
   - note: This is provided only as a hint, and the application is responsible for any
   coordinate transformations needed to conform to the requested display orientation.
   */
  public var panelOrientation: Int64 {
    (try? self.properties[SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER].get()?.wrappedValue as? Int64) ?? .zero
  }
  
  public var naturalOrientation: SDL_DisplayOrientation {
    SDL_DisplayOrientation(rawValue: __SDL_GetNaturalDisplayOrientation(id).rawValue) ?? .unknown
  }
  
  public var currentOrientation: SDL_DisplayOrientation {
    SDL_DisplayOrientation(rawValue: __SDL_GetCurrentDisplayOrientation(id).rawValue) ?? .unknown
  }

  private var properties: Result<SDL_PropertiesID, SDL_Error> {
    let propertyID = SDL_GetDisplayProperties(id)
    guard propertyID != 0 else { return .failure(.error) }
    
    return Result(catching: { try SDL_PropertiesID(id: id) })
      .mapError { $0 as! SDL_Error }
  }

  public var debugDescription: String {
    let name = (try? name.get()) ?? "<DISPLAY \(id): UNKNOWN NAME>"
    let bounds = (try? bounds.get()) ?? .zero
    let usable = (try? usableBounds.get()) ?? .zero
    let divider = Array.init(repeating: "-", count: name.count + 10).joined()
    return """
    DISPLAY: \(id)
    \(divider)
       Name: \(name)
     Bounds: (\(bounds.x), \(bounds.y)) (\(bounds.w), \(bounds.h))
     Usable: (\(usable.x), \(usable.y)) (\(usable.w), \(usable.h))
        HDR: \(isHDREnabled)
      Panel: \(panelOrientation)
    Natural: \(naturalOrientation)
    Current: \(currentOrientation)
    \(divider)
    """
  }
}

extension SDL_DisplayOrientation: @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .landscape: return "landscape"
      case .landscapeFlipped: return "landscapeFlipped"
      case .flipped: return "flipped"
      case .portrait: return "portrait"
      case .unknown: return "unknown"
      @unknown default: return "unknown"
    }
  }
}
