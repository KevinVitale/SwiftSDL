public final class SceneAction<Node: SceneNode>: Equatable, Hashable {
  public struct UpdateInfo {
    public let delta: Double
    public let elapsedTime: Double
    public let percentComplete: Double
  }
  
  typealias UpdateBlock = (_ node: Node, _ info: UpdateInfo) -> ()
  
  required init(atInterval duration: Double = .zero, _ callback: @escaping UpdateBlock) {
    self.block = callback
    self.duration = duration
  }
  
  private let    duration: Double
  private(set) var  block: UpdateBlock? = nil
  private let          id: UUID         = UUID()
  private var     repeats: Bool         = false
  
  public private(set) var isCancelled: Bool = false
  
  private var accumlatedTime: Double = .zero
  private var percentComplete: Double = .zero
  
  var speed: Double = 1.0
  
  public func update(node: Node, delta timeInterval: Double) {
    guard self.isCancelled == false else {
      return
    }
    
    let updateInfo = UpdateInfo(
      delta: timeInterval,
      elapsedTime: accumlatedTime,
      percentComplete: (duration <= 0 ? 1 : percentComplete)
    )
    block?(node, updateInfo)
    
    guard accumlatedTime <= duration else {
      if repeats {
        accumlatedTime = .zero
        percentComplete = .zero
      }
      else {
        isCancelled.toggle()
        // FIXME: restore 'detach'
        // node.detach(action: self as! Node.Actions.Element)
      }
      return
    }
    
    accumlatedTime += (timeInterval * speed * node.speed)
    percentComplete = (1 - (duration - accumlatedTime) / duration)
  }
  
  public func cancel() {
    self.isCancelled.toggle()
  }
  
  public func hash(into hasher: inout Hasher) {
    var this = self
    withUnsafeBytes(of: &this) {
      hasher.combine(bytes: $0)
    }
  }
  
  public static func == (lhs: SceneAction, rhs: SceneAction) -> Bool {
    lhs.id == rhs.id
  }
}

extension SceneAction {
  public class func customAction(duration: Double = .zero, _ callback: @escaping (_ node: Node, _ updateInfo: UpdateInfo) -> ()) -> Self {
    Self(atInterval: duration, callback)
  }
  
  public class func move(by delta: Point<Float>, duration: Double = .zero) -> Self {
    Self(atInterval: duration) { (node, updateInfo) in
      guard updateInfo.percentComplete < 1 else {
        return
      }
      
      let duration = Float(duration) * 1000
      
      node.position += delta * duration * Float(updateInfo.delta)
    }
  }
}
