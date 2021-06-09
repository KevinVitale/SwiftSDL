import Foundation
import CSDL2
import SwiftSDL2

class GameBoardRenderer: SpriteNode {
    required init(tileTexture: SDLTexture?, gameBoard: GameBoard = GameBoard()) throws {
        self.tileTexture = tileTexture
        self.gameBoard   = gameBoard
        super.init()
        
        self.tileSprites = try self.generateTileSprites()
        self.tileSprites.values.forEach {
            self.add(child: $0)
        }
    }
    
    private var gameBoard: GameBoard
    private var tileSprites: [Int:SpriteNode] = [:] {
        willSet {
            self.tileSprites.values.forEach {
                $0.removeFromParent()
            }
        }
        didSet {
            self.tileSprites.values.forEach {
                self.add(child: $0)
            }
        }
    }
    private weak var tileTexture: SDLTexture?
    private static let defaultTileColorBlendFactor: Double = 0.325
    
    private func generateTileSprites() throws -> [Int:SpriteNode] {
        var blocks   = [Int:SpriteNode]()
        
        var idx = 0
        gameBoard.forEach { index, _ in
            defer { idx += 1}
            
            let block              = SpriteNode(texture: tileTexture, scaledTo: scale)
            block.position.x       = block.size.x * Float(index.column)
            block.position.y       = block.size.y * Float(index.row)
            block.colorBlendFactor = GameBoardRenderer.defaultTileColorBlendFactor
            blocks[idx] = block
        }
        
        return blocks
    }
    
    func testStateChange(numberOfTile: Int) {
        self.gameBoard.clear()
        
        (0..<numberOfTile).forEach { _ in
            self.gameBoard[self.gameBoard.randomTileIndex] = 1
        }
        
        for (index, value) in self.gameBoard.enumerated() {
            let sprite = self.tileSprites[index]
            sprite?.colorBlendFactor = value != .zero ? 1.0 : GameBoardRenderer.defaultTileColorBlendFactor
        }
    }
}


