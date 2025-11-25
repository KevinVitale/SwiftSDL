extension SDL_PixelFormat: @retroactive CustomDebugStringConvertible {
  static func ==(lhs: SDL_PixelFormat, rhs: SDL_PixelType) -> Bool { lhs.pixelType == rhs }
  
  public init(bpp: Int32, red: Uint32 , green: Uint32, blue: Uint32, alpha: Uint32) {
    self = __SDL_GetPixelFormatForMasks(bpp, red, green, blue, alpha)
  }
  
  public init(masks: (bpp: Int32, red: Uint32 , green: Uint32, blue: Uint32, alpha: Uint32)) {
    self.init(bpp: masks.bpp, red: masks.red, green: masks.green, blue: masks.blue, alpha: masks.alpha)
  }

  private var order: UInt32 { (((rawValue) >> 20) & 0x0F) }
  private var flags: UInt32 { (((rawValue) >> 28) & 0x0F) }
  
  public var debugDescription: String {
    String(
      String(cString: SDL_GetPixelFormatName(self)).dropFirst(16)
    )
  }
  
  public var bitmapOrder: SDL_BitmapOrder { .init(rawValue: order) ?? .none }
  public var pixelOrder: SDL_PackedOrder { .init(rawValue: order) ?? .none }
  public var arrayOrder: SDL_ArrayOrder { .init(rawValue: order) ?? .none }

  public var pixelType: SDL_PixelType { .init(rawValue: (((rawValue) >> 24) & 0x0F)) ?? .unknown }
  public var isFourCC: Bool { rawValue != 0 && flags != 1 }
  public var packedLayout: SDL_PackedLayout { .init(rawValue: (((rawValue) >> 16) & 0x0F)) ?? .none }
  
  public var isIndexed: Bool {
    (!isFourCC &&
     (
      self == .index1 ||
      self == .index2 ||
      self == .index4 ||
      self == .index8
     )
    )
  }
  
  public var isPacked: Bool {
    (!isFourCC &&
     (
      self == .packed8 ||
      self == .packed16 ||
      self == .packed32
     )
    )
  }
  
  public var isArray: Bool {
    (!isFourCC &&
     (
      self == .arrayU8 ||
      self == .arrayU16 ||
      self == .arrayU32 ||
      self == .arrayF16 ||
      self == .arrayF32
     )
    )
  }
  
  public var is10bit: Bool {
    (!isFourCC &&
     (
      self == .packed32 ||
      self.packedLayout == ._2101010
     )
    )
  }
  
  public var isFloat: Bool {
    (!isFourCC &&
     (
      self == .arrayF16 ||
      self == .arrayF32
     )
    )
  }

  public var isAlpha: Bool {
    (isPacked &&
     (
      self.pixelOrder == .argb ||
      self.pixelOrder == .rgba ||
      self.pixelOrder == .abgr ||
      self.pixelOrder == .bgra
     )
    ) ||
    (isArray &&
     (
      self.arrayOrder == .argb ||
      self.arrayOrder == .rgba ||
      self.arrayOrder == .abgr ||
      self.arrayOrder == .bgra
     )
    )
  }

  public var bitsPerPixel: UInt32 { isFourCC ?
    0 : (((rawValue) >> 8) & 0xFF)
  }
  public var bytesPerPixel: UInt32 { isFourCC ? (
      self == .yuy2 || self == .uyvy || self == .yvyu || self == .p010 ? 2 : 1
    ) : (((rawValue) >> 0) & 0xFF)
  }
  
  public func masks() throws (SDL_Error) -> Result<(
    bpp: Uint32,
    red: Uint32,
    green: Uint32,
    blue: Uint32,
    alpha: Uint32
  ), SDL_Error> {
    var bpp: Uint32 = 0
    var red: Uint32 = 0
    var green: Uint32 = 0
    var blue: Uint32 = 0
    var alpha: Uint32 = 0
    guard __SDL_GetMasksForPixelFormat(
      self,
      &bpp,
      &red,
      &green,
      &blue,
      &alpha
    ) else {
      return .failure(.error)
    }
    return .success(
      (bpp: bpp,
       red: red,
       green: green,
       blue: blue,
       alpha: alpha
      )
    )
  }
  
  public func details() throws(SDL_Error) -> Result<SDL_PixelFormatDetails, SDL_Error> {
    guard let details = __SDL_GetPixelFormatDetails(self) else {
      return .failure(.error)
    }
    return .success(details.pointee)
  }
}
