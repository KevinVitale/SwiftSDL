import Foundation
import CSDL2
import SwiftSDL2

@available(OSX 10.12, *)
class MainScene: WindowScene {
    var gameBoardRenderer : GameBoardRenderer? {
        willSet {
            gameBoardRenderer?.removeFromParent()
        }
        didSet {
            if let gameBoardRenderer = gameBoardRenderer {
                self.add(child: gameBoardRenderer)
            }
        }
    }

    override func willPresent(to game: Game) throws {
        try super.willPresent(to: game)
        self.backgroundColor = SDL_Color(r: 38, g: 38, b: 38, a: 255)
    }
    
    override func update(atTime timeInterval: TimeInterval) {
        super.update(atTime: timeInterval)
        self.gameBoardRenderer?.update(atTime: timeInterval)
    }
    
    override func handleInput(from event: SDL_Event) {
        switch Int(event.key.keysym.sym) {
        default: ()
        }
    }
}

