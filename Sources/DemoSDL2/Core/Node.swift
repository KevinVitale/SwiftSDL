import Foundation
import CSDL2
import SwiftSDL2

class Node: Equatable, CustomStringConvertible {
    // MARK: - Private
    
    /// Node's raw position in 2D space.
    private var _position: SDL_FPoint = SDL_FPoint()
    
    /// Parent relationship.
    private(set) weak var parent: Node? = nil {
        willSet {
            removeFromParent()
        }
        didSet {
            parent?.children.append(self)
        }
    }
    
    /// Child nodes.
    private(set) var children: [Node] = []
    
    /// Actions
    private(set) var actions: [Action] = []
    
    // MARK: - Public
    /// Arbitruary data to attach to the node.
    var userData: [AnyHashable:Any]?
    
    /// The node's position, translated to by its parent node's position.
    var position: SDL_FPoint {
        get {
            var position = _position
            if let parent = self.parent {
                position.x += parent.position.x
                position.y += parent.position.y
            }
            return position
        }
        set {
            _position = newValue
        }
    }
    
    // MARK: - Description
    var description: String {
        "\(type(of: self))" + " (x: \(position.x), y: \(position.y))"
    }
    
    // MARK: - Translate
    func moveTo<T>(x: T, y: T) -> () -> () where T: BinaryInteger {
        return {
            self.position = SDL_FPoint(x: Float(x), y: Float(y))
        }
    }

    // MARK: - Node Graph
    func add(child node: Node) {
        node.parent = self
    }
    
    func removeFromParent() {
        self.parent?.remove(children: [self])
    }
    
    func removeAllChildren() {
        self.remove(children: self.children)
    }
    
    func remove(children nodes: [Node]) {
        self.children.removeAll(where: {
            guard nodes.contains($0) else {
                return false
            }
            return true
        })
    }
    
    func existsIn(heirarchyOf parent: Node) -> Bool {
        var currentParent = self.parent
        var doesExist = false
        while currentParent != nil {
            if currentParent == parent {
                doesExist = true
                break
            }
            currentParent = currentParent?.parent
        }
        return doesExist
    }
    
    func attach(actions: Action...) {
        self.actions += actions
    }

    // MARK: Equitability
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
    }
}

class SpriteNode: Node, Drawable {
    init(texture: SDLTexture? = nil, size: (x: Float, y: Float)? = nil, scaledTo scale: Float = 1.0, color: SDL_Color = SDL_Color(r: 255, g: 255, b: 255, a: 255)) {
        self.color   = color
        self.size    = size ?? (try? texture?.sizeF()) ?? (x: 0, y: 0)
        self.texture = texture
        self.scale   = scale
    }
    
    let size: (x: Float, y: Float)
    
    var            isFlipped: Bool = false
    var             isHidden: Bool = false
    var     colorBlendFactor: Double = 1.0
    private let        color: SDL_Color
    var              texture: SDLTexture?

    var scale: Float = 1.0
    var rotation: Double = 0
    var rect: SDL_FRect {
        SDL_FRect(x: position.x, y: position.y, w: position.x + size.x, h: position.y + size.y)
    }
    
    func contains(point: (x: Float, y: Float)) -> Bool {
        true
    }

    func draw(renderer: SDLRenderer?) {
        guard self.isHidden == false else {
            return
        }

        texture?.result(of: SDL_SetTextureColorMod, UInt8(Double(color.r) * colorBlendFactor), UInt8(Double(color.g) * colorBlendFactor), UInt8(Double(color.b) * colorBlendFactor))
        
        let sourceRect = SDL_Rect(x: 0, y: 0, w: Int32(size.x), h: Int32(size.y))
        let destRect   = SDL_Rect(x: Int32(position.x), y: Int32(position.y), w: Int32(size.x * scale), h: Int32(size.y * scale))
        
        renderer?.copy(from: texture, within: sourceRect, into: destRect, rotatedBy: rotation, flipped: self.isFlipped ? .horizontal : .none)
    }
}

protocol Drawable {
    func draw(renderer: SDLRenderer?)
}

protocol Updatable {
    func update(atTime timeInterval: TimeInterval)
}
