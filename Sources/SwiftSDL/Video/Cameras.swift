public final class CameraPtr: SDLPointer {
  public static func destroy(_ pointer: OpaquePointer) {
    SDL_CloseCamera(pointer)
  }
}

public struct Cameras {
  public static var available: Result<[CameraID], SDL_Error> {
    var cameraCount: Int32 = 0
    guard let camerasPtr = SDL_GetCameras(&cameraCount) else {
      return .failure(.error)
    }
    defer { SDL_free(camerasPtr) }
    
    var cameras = [CameraID](repeating: .invalid, count: Int(cameraCount))
    for index in 0..<Int(cameraCount) {
      cameras[index] = .available(camerasPtr[index])
    }
    
    return .success(cameras)
  }
  
  public typealias MatchingCallback = (
    (id: SDL_CameraID, name: String, position: SDL_CameraPosition),
    [SDL_CameraSpec], inout SDL_CameraSpec?)
  throws(SDL_Error) -> Bool
  
  public static func matching (_ block: MatchingCallback) throws(SDL_Error) -> CameraID? {
    let cameraIDs = try available.get()
    var cameraSpec: SDL_CameraSpec? = nil
    for cameraID in cameraIDs {
      let cameraName = try cameraID.name.get()
      let cameraSpecs = try cameraID.specs.get()
      let cameraPosition = cameraID.position
      let camera = (id: cameraID.id, name: cameraName, position: cameraPosition)
      
      if try block(camera, cameraSpecs, &cameraSpec) {
         return try cameraID.open(cameraSpec).get()
      }
    }
    return nil
  }
}

@dynamicMemberLookup
public enum CameraID: Decodable, CustomDebugStringConvertible {
  private enum CodingKeys: String, CodingKey {
    case cameraID
  }
  
  case available(SDL_CameraID)
  case open(pointer: CameraPtr.Value, frame: (surface: (any Surface)?, timestamp: UInt64), spec: SDL_CameraSpec?)
  case invalid
  
  /*
  public init(from decoder: any Decoder) throws {
    let decoder = try decoder.container(keyedBy: CodingKeys.self)
    let cameraID = try decoder.decode(SDL_CameraID.self, forKey: .cameraID)
    self = .available(cameraID)
  }
   */
  
  // FIXME: Is a system-wide camera probe occurring during decoding a good idea?
  public init(from decoder: any Decoder) throws {
    let decoder = try decoder.container(keyedBy: CodingKeys.self)
    let cameraID = try decoder.decode(SDL_CameraID.self, forKey: .cameraID)
    let available = try Cameras.available.get()
    guard available.contains(where: { $0.id == cameraID }) else {
      self = .invalid
      return
    }
    self = .available(cameraID)
  }
  
  public var id: SDL_CameraID {
    switch self {
      case .available(let id): return id
      case .open(let ptr, _, _): return SDL_GetCameraID(ptr)
      case .invalid: return .zero
    }
  }
  
  public var name: Result<String, SDL_Error> {
    guard let name = SDL_GetCameraName(id) else {
      return .failure(SDL_Error.error)
    }
    return .success(String(cString: name))
  }
  
  public var position: SDL_CameraPosition {
    SDL_GetCameraPosition(id)
  }
  
  public var spec: SDL_CameraSpec? {
    guard case(.open(_, _, let spec)) = self else {
      return nil
    }
    return spec
  }
  
  public var specs: Result<[SDL_CameraSpec], SDL_Error> {
    var specsCount: Int32 = 0
    guard let specsPtr = SDL_GetCameraSupportedFormats(id, &specsCount) else {
      return .failure(.error)
    }
    defer { SDL_free(specsPtr) }
    
    var specs = [SDL_CameraSpec](repeating: .init(), count: Int(specsCount))
    for index in 0..<Int(specsCount) {
      if let spec = specsPtr[index] {
        specs[index] = spec.pointee
      }
    }
    return .success(specs)
  }
  
  public subscript<T>(dynamicMember keyPath: KeyPath<SDL_CameraSpec, T>) -> T? {
    guard case(.open(_, _, let spec)) = self else {
      return nil
    }
    return spec?[keyPath: keyPath]
  }
  
  public subscript<T>(dynamicMember keyPath: KeyPath<any Surface, T>) -> T? {
    guard case(.open(_, let surface, _)) = self else {
      return nil
    }
    return surface.0?[keyPath: keyPath]
  }

  public func open(_ spec: SDL_CameraSpec? = nil) -> Result<Self, SDL_Error> {
    switch self {
      case .open: return .success(self)
      default:
        print("Opening:", self.id, try! self.name.get())
        if var spec = spec {
          guard let pointer = SDL_OpenCamera(id, &spec) else {
            return .failure(SDL_Error.error)
          }
          return .success(.open(pointer: pointer, frame: (nil, 0), spec: spec))
        }
        else {
          guard let pointer = SDL_OpenCamera(id, nil) else {
            return .failure(SDL_Error.error)
          }
          return .success(.open(pointer: pointer, frame: (nil, 0), spec: nil))
        }
    }
  }
  
  public mutating func close() {
    guard case(.open(let pointer, _, _)) = self else {
      return
    }
    self = .available(id)
    CameraPtr.destroy(pointer)
  }

  public var debugDescription: String {
    guard case(.success(let name)) = name else {
      return "INVALID CAMERA DEVICE"
    }
    return name
  }
  
  public mutating func draw(
    sourceRect: UnsafePointer<SDL_Rect>! = nil,
    to surface: any Surface,
    destRect: UnsafePointer<SDL_Rect>! = nil,
    scaleMode: SDL_ScaleMode = SDL_SCALEMODE_NEAREST
  ) throws(SDL_Error) {
    let frame = self._updateFrame()
    try frame.surface?(
      SDL_BlitSurfaceScaled,
      nil,
      surface.pointer,
      nil,
      SDL_SCALEMODE_NEAREST
    )
  }
  
  private mutating func _updateFrame() -> (surface: (any Surface)?, timestamp: UInt64) {
    guard case(.open(let pointer, let frame, _)) = self else {
      return (nil, 0)
    }
    var timestamped: UInt64 = 0
    guard let nextFrame = SDL_AcquireCameraFrame(pointer, .some(&timestamped)) else {
      return frame
    }
    
    SDL_ReleaseCameraFrame(pointer, frame.0?.pointer)

    let surface = SDLObject<SurfacePtr>(pointer: nextFrame)
    self = .open(pointer: pointer, frame: (surface, timestamped), spec: self.spec)
    return (surface, timestamped)
  }
}

public enum CameraDriver: CustomDebugStringConvertible {
  case name(String)
  
  public var debugDescription: String {
    switch self {
      case .name(let name): return name
    }
  }
  
  public static var available: Result<[CameraDriver], SDL_Error> {
    let driverCount = SDL_GetNumCameraDrivers()
    guard driverCount > 0 else {
      return .success([])
    }
    
    var drivers = [CameraDriver]()
    for index in 0..<Int(driverCount) {
      let driver = String(cString: SDL_GetCameraDriver(Int32(index)))
      drivers.append(.name(driver))
    }
    
    return .success(drivers)
  }

  public static var current: CameraDriver? {
    guard let current = SDL_GetCurrentCameraDriver() else {
      return nil
    }
    let driver = String(cString: current)
    return .name(driver)
  }
}

public enum SDL_CameraPermissionState: Int32, CustomDebugStringConvertible {
  case approved
  case denied
  case unknown
  
  public var debugDescription: String {
    switch self {
      case .approved: return "approved"
      case .denied: return "denied"
      case .unknown: return "unknown"
    }
  }
}

extension SDL_CameraSpec: @retroactive Equatable {
  public static func == (lhs: SDL_CameraSpec, rhs: SDL_CameraSpec) -> Bool {
    lhs.colorspace.rawValue == rhs.colorspace.rawValue &&
    lhs.format.rawValue == rhs.format.rawValue &&
    lhs.width == rhs.width &&
    lhs.height == rhs.height &&
    lhs.framerate_numerator == rhs.framerate_numerator &&
    lhs.framerate_denominator == rhs.framerate_denominator
  }
}

extension SDL_CameraSpec: @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    """
    Pixel Format: \(format.rawValue)
    Colorspace:   \(colorspace.rawValue)
    Size:         \(width), \(height)
    FPS:          \(framesPerSecond)
    Duration:     \(frameDuration)
    """
  }
  
  public var framesPerSecond: Double {
    Double(framerate_numerator) / Double(framerate_denominator)
  }
  
  public var frameDuration: Double {
    Double(framerate_denominator) / Double(framerate_numerator)
  }
}

extension SDL_CameraPosition: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let unknown = SDL_CAMERA_POSITION_UNKNOWN
  public static let frontFacing = SDL_CAMERA_POSITION_FRONT_FACING
  public static let backFacing = SDL_CAMERA_POSITION_BACK_FACING
  
  public static var allCases: [Self] {
    [
      .unknown,
      .backFacing,
      .frontFacing
    ]
  }
  
  public var debugDescription: String {
    switch self {
      case .unknown: return "unknown"
      case .backFacing: return "backFacing"
      case .frontFacing: return "frontFacint"
      default: return "Unknown SDL_CameraPosition: \(self)"
    }
  }
}

