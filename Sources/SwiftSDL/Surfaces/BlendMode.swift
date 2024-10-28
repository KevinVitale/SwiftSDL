extension Flags {
  public enum BlendMode: SDL_Flag, Decodable {
    public init(rawValue: Uint32) {
      switch rawValue {
        case SDL_BLENDMODE_NONE:                self = .none
        case SDL_BLENDMODE_BLEND:               self = .blend
        case SDL_BLENDMODE_BLEND_PREMULTIPLIED: self = .blendPremul
        case SDL_BLENDMODE_ADD:                 self = .add
        case SDL_BLENDMODE_ADD_PREMULTIPLIED:   self = .addPremul
        case SDL_BLENDMODE_MOD:                 self = .mod
        case SDL_BLENDMODE_MUL:                 self = .mul
        case SDL_BLENDMODE_INVALID:             self = .invalid
        default: self = .invalid
      }
    }
    
    case none
    case blend
    case blendPremul
    case add
    case addPremul
    case mod
    case mul
    case invalid
    
    public var debugDescription: String {
      switch self {
        case .none:         return "none"
        case .blend:        return "blend"
        case .blendPremul:  return "blendPremul"
        case .add:          return "add"
        case .addPremul:    return "addPremul"
        case .mod:          return "mod"
        case .mul:          return "mul"
        case .invalid:      return "invalid"
      }
    }
    
    public var rawValue: UInt32 {
      switch self {
        case .none:        return SDL_BLENDMODE_NONE
        case .blend:       return SDL_BLENDMODE_BLEND
        case .blendPremul: return SDL_BLENDMODE_BLEND_PREMULTIPLIED
        case .add:         return SDL_BLENDMODE_ADD
        case .addPremul:   return SDL_BLENDMODE_ADD_PREMULTIPLIED
        case .mod:         return SDL_BLENDMODE_MOD
        case .mul:         return SDL_BLENDMODE_MUL
        case .invalid:     return SDL_BLENDMODE_INVALID
      }
    }
    
    public static var allCases: [Self] {
      [
        .none,
        .blend,
        .blendPremul,
        .add,
        .addPremul,
        .mod,
        .mul,
        .invalid
      ]
    }
  }
}

extension Flags.BlendMode: ExpressibleByArgument {
  public var defaultValueDescription: String {
    Self.none.debugDescription
  }
  
  public static var allValueStrings: [String] {
    Self.allCases.filter({
      switch $0 {
        case .add: fallthrough
        case .blend: fallthrough
        case .mul: fallthrough
        case .mod: return true
        default: return false
      }
    }).map(\.debugDescription)
  }
}

