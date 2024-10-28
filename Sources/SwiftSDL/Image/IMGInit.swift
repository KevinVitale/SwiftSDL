#if canImport(SDL3_Image)
extension Flags {
  public enum InitIMG: SDL_Flag {
    public init(rawValue: UInt32) {
      switch rawValue {
        case UInt32(IMG_INIT_JPG)  : self = .jpg
        case UInt32(IMG_INIT_PNG)  : self = .png
        case UInt32(IMG_INIT_TIF)  : self = .tif
        case UInt32(IMG_INIT_WEBP) : self = .webp
        case UInt32(IMG_INIT_JXL)  : self = .jxl
        case UInt32(IMG_INIT_AVIF) : self = .avif
        default: self = .invalid
      }
    }
    
    case jpg
    case png
    case tif
    case webp
    case jxl
    case avif
    case invalid
    
    public var debugDescription: String {
      switch self {
        case .jpg:  return "jpg"
        case .png:  return "png"
        case .tif:  return "tif"
        case .webp: return "webp"
        case .jxl:  return "jxl"
        case .avif: return "avif"
        case .invalid:  return "invalid"
      }
    }
    
    public var rawValue: IMG_InitFlags {
      switch self {
        case .jpg:  return UInt32(IMG_INIT_JPG)
        case .png:  return UInt32(IMG_INIT_PNG)
        case .tif:  return UInt32(IMG_INIT_TIF)
        case .webp: return UInt32(IMG_INIT_WEBP)
        case .jxl:  return UInt32(IMG_INIT_JXL)
        case .avif: return UInt32(IMG_INIT_AVIF)
        case .invalid: return 0
      }
    }
    
    public static var allCases: [Self] {
      [
        .jpg,
        .png,
        .tif,
        .webp,
        .jxl,
        .avif,
        .invalid
      ]
    }
  }
}

@discardableResult
public func IMG_Init(_ flags: Flags.InitIMG...) -> Flags.InitIMG.RawValue {
  IMG_Init(flags.reduce(0) { $0 | $1.rawValue })
}
#endif
