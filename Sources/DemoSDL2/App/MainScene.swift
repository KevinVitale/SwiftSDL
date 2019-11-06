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

    override func update(atTime timeInterval: TimeInterval) {
        super.update(atTime: timeInterval)
        self.gameBoardRenderer?.update(atTime: timeInterval)
    }
}

