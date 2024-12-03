public enum SDL_BlendMode: RawRepresentable, CustomDebugStringConvertible, Sendable {
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

extension SDL_BlendOperation: @retroactive CustomDebugStringConvertible {
  /** dst + src: supported by all renderers */
  public static let add = SDL_BLENDOPERATION_ADD
  
  /** src - dst : supported by D3D, OpenGL, OpenGLES, and Vulkan */
  public static let substract = SDL_BLENDOPERATION_SUBTRACT
  
  /** dst - src : supported by D3D, OpenGL, OpenGLES, and Vulkan */
  public static let reverseSubtract = SDL_BLENDOPERATION_REV_SUBTRACT
  
  /** min(dst, src) : supported by D3D, OpenGL, OpenGLES, and Vulkan */
  public static let minium = SDL_BLENDOPERATION_MINIMUM
  
  /** max(dst, src) : supported by D3D, OpenGL, OpenGLES, and Vulkan */
  public static let maximum = SDL_BLENDOPERATION_MAXIMUM
  
  public var debugDescription: String {
    switch self {
      case SDL_BLENDOPERATION_ADD: return "add"
      case SDL_BLENDOPERATION_SUBTRACT: return "subtract"
      case SDL_BLENDOPERATION_REV_SUBTRACT: return "reverse subtract"
      case SDL_BLENDOPERATION_MINIMUM: return "minimum"
      case SDL_BLENDOPERATION_MAXIMUM: return "maximum"
      default: return "Unknown SDL_BlendOperation: \(self)"
    }
  }
}

extension SDL_BlendFactor {
  /** 0, 0, 0, 0 */
  public static let zeor = SDL_BLENDFACTOR_ZERO
  
  /** 1, 1, 1, 1 */
  public static let one = SDL_BLENDFACTOR_ONE
  
  /** srcR, srcG, srcB, srcA */
  public static let sourceColor = SDL_BLENDFACTOR_SRC_COLOR
  
  /** 1-srcR, 1-srcG, 1-srcB, 1-srcA */
  public static let oneMinusSourceColor = SDL_BLENDFACTOR_ONE_MINUS_SRC_COLOR
  
  /** srcA, srcA, srcA, srcA */
  public static let alpha = SDL_BLENDFACTOR_SRC_ALPHA
  
  /** 1-srcA, 1-srcA, 1-srcA, 1-srcA */
  public static let oneMinusSourceAlpha = SDL_BLENDFACTOR_ONE_MINUS_SRC_ALPHA
  
  /** dstR, dstG, dstB, dstA */
  public static let destinationColor = SDL_BLENDFACTOR_DST_COLOR
  
  /** 1-dstR, 1-dstG, 1-dstB, 1-dstA */
  public static let oneMinusDestinationColor = SDL_BLENDFACTOR_ONE_MINUS_DST_COLOR
  
  /** dstA, dstA, dstA, dstA */
  public static let destinationAlpha = SDL_BLENDFACTOR_DST_ALPHA
  
  /** 1-dstA, 1-dstA, 1-dstA, 1-dstA */
  public static let oneMinusDestinationAlpha = SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA
}
