extension SDL_SensorType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .invalid: return "invalid"
      case .unknown: return "unknown"
      case .accelerometer: return "accelerometer"
      case .gyroscope: return "gyroscope"
      case .accelerometerLeft: return "accelerometer (L)"
      case .gyroscopeLeft: return "gyroscope (L)"
      case .accelerometerRight: return "accelerometer (R)"
      case .gryoscopeRight: return "gyroscope (R)"
      default: return "Unknown SDL_SensorType: \(self.rawValue)"
    }
  }
  
  public static var allCases: [SDL_SensorType] {
    [
      .invalid,
      .unknown,
      .accelerometer,
      .gyroscope,
      .accelerometerLeft,
      .gyroscopeLeft,
      .accelerometerRight,
      .gryoscopeRight
    ]
  }
}

public enum SDL_SensorData {
  case accelerometer(x: Float, y: Float, z: Float)
  case gyroscope(pitch: Float, yaw: Float, roll: Float)
  case none
}
