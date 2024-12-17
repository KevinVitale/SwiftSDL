protocol AnimationState: Identifiable where ID == Int {
  var frameSize: Size<Float> { get }
  
  func frameDuration(for frame: Int) -> Float
  func nextFrame(after frame: Int) -> Int
}

extension SDL.Games {
  enum AnyAnimation: AnimationState {
    case unknown
    case state(any AnimationState)

    var frameSize: SwiftSDL.Size<Float> {
      switch self {
        case .state(let state): return state.frameSize
        default: return .zero
      }
    }
    
    func frameDuration(for frame: Int) -> Float {
      switch self {
        case .state(let state): return state.frameDuration(for: frame)
        default: return .zero
      }
    }
    
    func nextFrame(after frame: Int) -> Int {
      switch self {
        case .state(let state): return state.nextFrame(after: frame)
        default: return .zero
      }
    }
    
    var id: Int {
      switch self {
        case .state(let state): return state.id
        default: return .zero
      }
    }
  }
}
