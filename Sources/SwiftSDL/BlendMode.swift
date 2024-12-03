public enum SDL_BlendMode: RawRepresentable, CustomDebugStringConvertible {
  case none
  case blend
  case blendPremul
  case add
  case addPremul
  case mod
  case mul
  case invalid
  case custom(
    srcColorFactor: SDL_BlendFactor,
    dstColorFactor: SDL_BlendFactor,
    colorOperation: SDL_BlendOperation,
    srcAlphaFactor: SDL_BlendFactor,
    dstAlphaFactor: SDL_BlendFactor,
    alphaOperation: SDL_BlendOperation
  )
  
  public init?(rawValue: UInt32) {
    switch rawValue {
      case SDL_BLENDMODE_NONE:                 self = .none
      case SDL_BLENDMODE_BLEND:                self = .blend
      case SDL_BLENDMODE_BLEND_PREMULTIPLIED:  self = .blendPremul
      case SDL_BLENDMODE_ADD:                  self = .add
      case SDL_BLENDMODE_ADD_PREMULTIPLIED:    self = .addPremul
      case SDL_BLENDMODE_MOD:                  self = .mod
      case SDL_BLENDMODE_MUL:                  self = .mul
      case SDL_BLENDMODE_INVALID:              self = .invalid
      default:                                 return nil
    }
  }

  public var rawValue: UInt32 {
    switch self {
      case .none:                 return SDL_BLENDMODE_NONE
      case .blend:                return SDL_BLENDMODE_BLEND
      case .blendPremul:          return SDL_BLENDMODE_BLEND_PREMULTIPLIED
      case .add:                  return SDL_BLENDMODE_ADD
      case .addPremul:            return SDL_BLENDMODE_ADD_PREMULTIPLIED
      case .mod:                  return SDL_BLENDMODE_MOD
      case .mul:                  return SDL_BLENDMODE_MUL
      case .invalid:              return SDL_BLENDMODE_INVALID
      case .custom(
        let srcColorFactor,
        let dstColorFactor,
        let colorOperation,
        let srcAlphaFactor,
        let dstAlphaFactor,
        let alphaOperation
      ): return SDL_ComposeCustomBlendMode(srcColorFactor, dstColorFactor, colorOperation, srcAlphaFactor, dstAlphaFactor, alphaOperation)
    }
  }
  
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
      case .custom:       return "custom"
    }
  }
}
