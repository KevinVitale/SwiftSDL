extension SDL_SensorType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let invalid = SDL_SENSOR_INVALID
  public static let unknown = SDL_SENSOR_UNKNOWN
  public static let accelerometer = SDL_SENSOR_ACCEL
  public static let gyroscope = SDL_SENSOR_GYRO
  public static let leftAccelerometer = SDL_SENSOR_ACCEL_L
  public static let leftGyroscope = SDL_SENSOR_GYRO_L
  public static let rightAccelerometer = SDL_SENSOR_ACCEL_R
  public static let rightGyroscope = SDL_SENSOR_GYRO_R
  
  public var debugDescription: String {
    switch self {
      case .invalid: return "invalid"
      case .unknown: return "unknown"
      case .accelerometer: return "accelerometer"
      case .gyroscope: return "gyroscope"
      case .leftAccelerometer: return "accelerometer (L)"
      case .leftGyroscope: return "gyroscope (L)"
      case .rightAccelerometer: return "accelerometer (R)"
      case .rightGyroscope: return "gyroscope (R)"
      default: return "Unknown SDL_SensorType: \(self.rawValue)"
    }
  }
  
  public static var allCases: [SDL_SensorType] {
    [
      .invalid,
      .unknown,
      .accelerometer,
      .gyroscope,
      .leftAccelerometer,
      .leftGyroscope,
      .rightAccelerometer,
      .rightGyroscope
    ]
  }
}
