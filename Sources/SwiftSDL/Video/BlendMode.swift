extension Flags {
  public enum BlendMode: SDL_Flag {
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
    
    public var rawValue: SDL_InitFlags {
      switch self {
        case .none:        return SDL_INIT_AUDIO
        case .blend:       return SDL_INIT_VIDEO
        case .blendPremul: return SDL_INIT_JOYSTICK
        case .add:         return SDL_INIT_HAPTIC
        case .addPremul:   return SDL_INIT_GAMEPAD
        case .mod:         return SDL_INIT_EVENTS
        case .mul:         return SDL_INIT_SENSOR
        case .invalid:     return SDL_INIT_CAMERA
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
