import Collections

open class SceneNode: Hashable, CustomDebugStringConvertible, Decodable {
  public typealias Child    = SceneNode
  public typealias Children = TreeSet<Child>
  
  public required init(_ label: String = "") {
    self.label = label
  }
  
  public var label: String = ""
  public var id = UUID()
  
  public var rotation: Measurement<UnitAngle> = .init(value: 0, unit: .degrees)
  public var speed: Double = 1
  
  public var position: Point<Float> {
    get { _position + (parent.position ?? .zero) }
    set { _position = newValue }
  }
  private var _position: Point<Float> = .zero
  
  public var scale: Size<Float> {
    get { _scale * (parent.scale ?? .one) }
    set { _scale = newValue }
  }
  private var _scale: Point<Float> = .one


  public var isHidden: Bool = false
  public var isPaused: Bool = false
  public var zPosition: Float = .zero
  
  public var isOrphaned: Bool { parent == .none }
  public var parent: Parent = .none
  public private(set) var children: Children = []
  
  public var debugDescription: String {
    """
    Node:     \(id)
    Label:    \(label.isEmpty ? "<NONE>" : label)
    IsHidden: \(isHidden)
    Orphaned: \(isOrphaned)
    Position: (x: \(position.x), y: \(position.y))
    Children: \(children.count)
    """
  }
  
  @discardableResult
  public func addChild(_ child: Child) -> Child? {
    guard child.isOrphaned else {
      return nil
    }
    child.parent = .parent(self)
    children.update(with: child)
    return child
  }
  
  @discardableResult
  public func addChildren(_ children: [Child]) -> [Child] {
    children.forEach { addChild($0) }
    return children
  }
  
  @discardableResult
  public func addChildren(_ children: Child...) -> [Child] {
    addChildren(children)
  }
  
  @discardableResult
  public func child(matching label: String) -> Child? {
    return children.filter({
      $0.label.elementsEqual(label)
    })
    .first
  }
  
  public func removeChildren(_ otherChildren: Child...) {
    otherChildren
      .filter({ $0.parent == self })
      .forEach({ $0.removeFromParent(); children.remove($0) })
  }
  
  public func removeAllChildren() {
    children
      .filter({ $0.parent == self })
      .forEach({ $0.removeAllChildren(); children.remove($0) })
  }

  public func removeFromParent() {
    parent = .none
  }
  
  public func move(to parent: Parent) {
    removeFromParent()
    self.parent = parent
  }
  
  public static func == (lhs: SceneNode, rhs: SceneNode) -> Bool {
    lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id.hashValue)
  }
}

extension SceneNode {
  @dynamicMemberLookup
  public enum Parent: Decodable, Hashable, CustomDebugStringConvertible {
    case none
    case parent(SceneNode?)
    
    public var debugDescription: String {
      switch self {
        case .none: return "orphaned"
        case .parent(let parent): return parent?.debugDescription ?? ""
      }
    }
    
    private var parent: SceneNode? {
      switch self {
        case .none: return nil
        case .parent(let parent): return parent
      }
    }
    
    internal var scene: (any SceneProtocol)? {
      guard case(.parent(let parent)) = self, let parent = parent as? (any SceneProtocol) else {
        return parent?.scene
      }
      return parent
    }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<SceneNode, Value>) -> Value? {
      parent?[keyPath: keyPath]
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
        case (.none, .none): return true
        case (.parent(let l), .parent(let r)): return l == r
        default: return false
      }
    }
    
    public static func == (lhs: Self, rhs: SceneNode) -> Bool {
      switch (lhs, rhs) {
        case (.parent(let l), let r): return l == r
        default: return false
      }
    }
  }
}
