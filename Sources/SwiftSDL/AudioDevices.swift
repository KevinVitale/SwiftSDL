public enum AudioDevices {
  public enum DeviceIntent {
    case playback
    case recording
    
    fileprivate var getFunc: @Sendable (UnsafeMutablePointer<Int32>?) -> UnsafeMutablePointer<SDL_AudioDeviceID>? {
      switch self {
        case .playback: return SDL_GetAudioPlaybackDevices
        case .recording: return SDL_GetAudioRecordingDevices
      }
    }
  }
  
  public static func available(for deviceIntent: DeviceIntent) -> Result<[AudioDeviceID], SDL_Error> {
    var deviceCount: Int32 = 0
    guard let bufferPtr = deviceIntent.getFunc(&deviceCount) else {
      return .failure(.error)
    }
    defer { SDL_free(bufferPtr) }
    
    var devices = [AudioDeviceID](repeating: .invalid, count: Int(deviceCount))
    for index in 0..<Int(deviceCount) {
      devices[index] = .available(bufferPtr[index])
    }
    
    return .success(devices)
  }
}

@dynamicMemberLookup
public enum AudioDeviceID: Decodable, CustomDebugStringConvertible {
  private enum CodingKeys: String, CodingKey {
    case deviceID
  }
  
  case available(SDL_AudioDeviceID)
  case defaultPlayback
  case defaultRecording
  case invalid

  public init(from decoder: any Decoder) throws {
    let decoder = try decoder.container(keyedBy: CodingKeys.self)
    let deviceID = try decoder.decode(SDL_AudioDeviceID.self, forKey: .deviceID)
    switch deviceID {
      case SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK: self = .defaultPlayback
      case SDL_AUDIO_DEVICE_DEFAULT_RECORDING: self = .defaultRecording
      default: self = .available(deviceID)
    }
  }
  
  public var id: SDL_AudioDeviceID {
    switch self {
      case .available(let id): return id
      case .defaultPlayback: return SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK
      case .defaultRecording: return SDL_AUDIO_DEVICE_DEFAULT_RECORDING
      case .invalid: return .zero
    }
  }
  
  public var name: Result<String, SDL_Error> {
    switch self {
      case .defaultPlayback: return .success("Default Playback Device")
      case .defaultRecording: return .success("Default Recording Device")
      default:
        guard let name = SDL_GetAudioDeviceName(id) else {
          return .failure(SDL_Error.error)
        }
        return .success(String(cString: name))
    }
  }
  
  public var spec: Result<(SDL_AudioSpec, bufferSize: Int32), SDL_Error> {
    var spec: SDL_AudioSpec! = .init()
    var frames: Int32 = 0
    guard SDL_GetAudioDeviceFormat(id, &spec, &frames) else {
      return .failure(SDL_Error.error)
    }
    return .success((spec, bufferSize: frames))
  }
  
  public subscript<T>(dynamicMember keyPath: KeyPath<SDL_AudioSpec, T>) -> T? {
    guard case(.success(let spec)) = spec else {
      return nil
    }
    return spec.0[keyPath: keyPath]
  }
  
  public var debugDescription: String {
    guard case(.success(let name)) = name else {
      return "INVALID AUDIO DEVICE"
    }
    return name
  }
}

public enum AudioDriver: CustomDebugStringConvertible {
  case name(String)
  
  public var debugDescription: String {
    switch self {
      case .name(let name): return name
    }
  }
  
  public static var available: Result<[Self], SDL_Error> {
    let driverCount = SDL_GetNumAudioDrivers()
    guard driverCount > 0 else {
      return .success([])
    }
    
    var drivers = [Self]()
    for index in 0..<Int(driverCount) {
      let driver = String(cString: SDL_GetAudioDriver(Int32(index)))
      drivers.append(.name(driver))
    }
    
    return .success(drivers)
  }
  
  public static var current: Self? {
    guard let current = SDL_GetCurrentAudioDriver() else {
      return nil
    }
    let driver = String(cString: current)
    return .name(driver)
  }
}

