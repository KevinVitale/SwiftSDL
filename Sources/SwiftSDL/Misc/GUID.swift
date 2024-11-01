extension SDL_GUID: @retroactive CustomDebugStringConvertible {
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
