import Foundation
import CSDL2
import SwiftSDL2

class WindowScene: SpriteNode, Identifiable {
    convenience init(backgroundColor: SDL_Color) {
        self.init()
        self.backgroundColor = backgroundColor
    }
    
    var backgroundColor: SDL_Color = SDL_Color()

    override func draw(renderer: SDLRenderer?) {
        renderer?.result(of: SDL_SetRenderDrawColor, backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
        renderer?.result(of: SDL_RenderClear)
        
        self.draw(children: self.children, renderer: renderer)
        
        renderer?.pass(to: SDL_RenderPresent)
    }

    private func draw<N: Node>(children: [N], renderer: SDLRenderer?) {
        children.forEach { node in
            if let node = node as? Drawable {
                node.draw(renderer: renderer)
            }
            self.draw(children: node.children, renderer: renderer)
        }
    }
}
