extension SDL_GUID: @retroactive CustomDebugStringConvertible {
  var bytes: [UInt8] {
    var data = self.data
    return withUnsafePointer(to: &data.0) {
      [UInt8](UnsafeBufferPointer(start: $0, count: 16))
    }
  }
  
  var isZero: Bool { (bytes.reduce(0) { $0 &+ $1 }) != 0 }
  
  public var debugDescription: String {
    var bytes = [UInt8].init(repeating: 0, count: 33)
    SDL_GUIDToString(self, bytes.withUnsafeMutableBufferPointer(\.baseAddress), Int32(bytes.count))
    return String(
      decoding: bytes,
      as: Unicode.ASCII.self
    )
    .uppercased()
  }
}
