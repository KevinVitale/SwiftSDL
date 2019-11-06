import Foundation
import CSDL2
import SwiftSDL2

class Scene: SpriteNode, Identifiable {
    convenience init(backgroundColor: SDL_Color) {
        self.init()
        self.backgroundColor = backgroundColor
    }
    
    var backgroundColor: SDL_Color = SDL_Color()

    override func draw(renderer: SDLRenderer?) {
        do {
            try renderer?.result(of: SDL_SetRenderDrawColor, backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a).get()
            try renderer?.result(of: SDL_RenderClear).get()
            
            self.drawChildren(self.children, renderer: renderer)
            
            renderer?.pass(to: SDL_RenderPresent)
        } catch {
            print(error)
        }
    }

    private func drawChildren<N: Node>(_ children: [N], renderer: SDLRenderer?) {
        children
            .compactMap({ $0 as? (Drawable & Node) })
            .forEach({
                self.drawChildren($0.children, renderer: renderer)
                $0.draw(renderer: renderer)
            })
    }
}
