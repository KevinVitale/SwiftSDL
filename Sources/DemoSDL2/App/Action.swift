import Foundation
import SwiftSDL2

class Action: Hashable, Equatable, Updatable {
    typealias UpdateBlock = (_ elapsedTime: TimeInterval) -> ()
    
    fileprivate init(atInterval duration: TimeInterval = .zero, _ callback: @escaping (_ node: Node, _ elaspedTime: TimeInterval) -> ()) {
        var weak_self: Action!
        self.block = {
            if let node = weak_self.node {
                callback(node, $0)
            }
        }
        self.duration = duration
        weak_self = self
    }

    private(set) var  block: UpdateBlock? = nil
    private let          id: UUID         = UUID()
    private var     repeats: Bool         = false
    private var       speed: Double       = 1.0
    private var    duration: TimeInterval = .zero
    private var isCancelled: Bool         = false

    private var  previousUpdateTime: TimeInterval = .infinity
    private var remainingUpdateTime: TimeInterval = .zero
    
    fileprivate var node: Node? = nil

    func update(atTime timeInterval: TimeInterval) {
        guard self.isCancelled == false else {
            return
        }
        
        if self.previousUpdateTime.isInfinite {
            self.previousUpdateTime = timeInterval
        }

        self.remainingUpdateTime -= (timeInterval - self.previousUpdateTime) * self.speed

        if let block = self.block, self.remainingUpdateTime.isLessThanOrEqualTo(.zero) {
            block(self.remainingUpdateTime)
            self.remainingUpdateTime = self.duration
        }
        
        if self.repeats == false {
            self.block = nil
        }
        
        self.previousUpdateTime = timeInterval
    }
    
    func cancel() {
        self.isCancelled.toggle()
    }
    
    func hash(into hasher: inout Hasher) {
        self.id.hash(into: &hasher)
    }

    static func == (lhs: Action, rhs: Action) -> Bool {
        lhs.id == rhs.id
    }
}

extension Action {
    func map(_ block: (Action) -> Action) -> Action {
        block(self)
    }
    
    open class func move(by delta: (x: Float, y: Float), duration: TimeInterval) -> Action {
        Action(atInterval: duration) { (node, elapsedTime) in
            let xPos = delta.x * Float(elapsedTime)
            let yPos = delta.y * Float(elapsedTime)
            node.moveTo(x: Int(node.position.x + xPos), y: Int(node.position.y + yPos))()
        }
    }
    
    open class func customAction(duration: TimeInterval, _ callback: @escaping (_ node: Node, _ elapsedTime: TimeInterval) -> ()) -> Action {
        Action(atInterval: duration, callback)
    }
    
    open class func repeatsForever(_ action: Action) -> Action {
        action.repeats = true
        return action
    }
    
    open class func animate(_ textures: [SDLTexture], frameDuration: TimeInterval) -> Action {
        var textureIndex = textures.startIndex
        return Action(atInterval: frameDuration) { node, elapsedTime in
            if let node = node as? SpriteNode {
                node.texture = textures[textureIndex]
                textureIndex = textures.index(after: textureIndex)
                if textureIndex >= textures.endIndex {
                    textureIndex = textures.startIndex
                }
            }
        }
    }
}

extension Node {
    func run(_ action: Action) {
        action.node = self
        self.attach(actions: action)
    }
}
