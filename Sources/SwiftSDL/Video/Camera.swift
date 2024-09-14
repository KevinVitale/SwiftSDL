
public final class SDL_Camera: SDLObjectProtocol {
  public typealias Pointer = CameraPtr
  public typealias Frame = Result<((any Surface)?, UInt64), SDL_Error>
  
  private init(id: SDL_CameraID, spec: SDL_CameraSpec? = nil) throws(SDL_Error) {
    if var spec = spec {
      guard let pointer = SDL_OpenCamera(id, &spec) else {
        throw SDL_Error.error
      }
      self.pointer = pointer
    }
    else {
      guard let pointer = SDL_OpenCamera(id, nil) else {
        throw SDL_Error.error
      }
      self.pointer = pointer
    }
  }
  
  public let pointer: Pointer.Value
  
  private var _activeFrame: (any Surface)?
  
  public var frame: Frame {
    return Frame { () throws(SDL_Error) -> ((any Surface)?, UInt64) in
      var timestamped: UInt64 = 0
      guard case(.success(let nextFrame)) = self.resultOf(SDL_AcquireCameraFrame, .some(&timestamped)) else {
        return (_activeFrame, timestamped)
      }
      
      try resultOf(SDL_ReleaseCameraFrame, _activeFrame?.pointer).get()
      _activeFrame = SDLObject(pointer: nextFrame)
      
      return (_activeFrame, timestamped)
    }
  }
}

extension SDL_Camera {
  public typealias MatchingCallback = (
    (id: SDL_CameraID, name: String, position: SDL_CameraPosition),
    [SDL_CameraSpec], inout SDL_CameraSpec?)
  throws(SDL_Error) -> Bool
  
  public static func matching (_ block: MatchingCallback) throws(SDL_Error) -> Self? {
    let cameraIDs = try SDL_GetCameras().get()
    var cameraSpec: SDL_CameraSpec? = nil
    for cameraID in cameraIDs {
      guard let name = SDL_GetCameraName(cameraID) else {
        throw SDL_Error.error
      }
      let cameraName = String(cString: name)
      let cameraSpecs = try SDL_GetCameraSupportedFormats(cameraID).get()
      let cameraPosition = SDL_GetCameraPosition(cameraID)
      let camera = (cameraID, cameraName, cameraPosition)
      
      if try block(camera, cameraSpecs, &cameraSpec) {
        return try self.init(id: cameraID, spec: cameraSpec)
      }
    }
    return nil
  }
}

public final class CameraPtr: SDLPointer {
  public static func destroy(_ pointer: OpaquePointer) {
    SDL_CloseCamera(pointer)
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

fileprivate func SDL_GetCameras() -> Result<[SDL_CameraID], SDL_Error> {
  var cameraCount: Int32 = 0
  guard let camerasPtr = SDL_GetCameras(&cameraCount) else {
    return .failure(.error)
  }
  defer { SDL_free(camerasPtr) }
  
  var cameras = [SDL_CameraID](repeating: .init(), count: Int(cameraCount))
  for index in 0..<Int(cameraCount) {
    cameras[index] = camerasPtr[index]
  }
  
  return .success(cameras)
}

fileprivate func SDL_GetCameraSupportedFormats(_ id: SDL_CameraID) -> Result<[SDL_CameraSpec], SDL_Error> {
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
