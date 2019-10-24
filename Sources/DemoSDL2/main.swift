import Foundation
import CSDL2
import SwiftSDL2

class AnimateTexture: Action {
    init(spriteNode: SpriteNode, textures: [Texture], atInterval timeInterval: TimeInterval) {
        var weak_self: AnimateTexture! = nil
        
        super.init(repeats: true, atInterval: timeInterval) { _ in
            defer { spriteNode.texture = weak_self?.texture }
            weak_self.textureIndex = textures.index(after: weak_self.textureIndex)
            if weak_self.textureIndex >= textures.endIndex {
                weak_self.textureIndex = textures.startIndex
            }
        }
        self.textures = textures

        weak_self = self
    }
    
    private var textureIndex = 0
    private var textures: [Texture] = []
    private weak var spriteNode: SpriteNode?
    
    var texture: Texture? {
        textures[textureIndex]
    }
}

func LoadCharacterSprites(format: SDL_PixelFormatEnum.RawValue, sizedAt size: (x: Float, y: Float) = (x: 32, y: 32), into renderer: Renderer?, resourceURL sourceURL: URL = Bundle.main.resourceURL!, atlasName: String) throws -> [[Texture]] {
    let sourceTexture  = try Texture.load(into: renderer, resourceURL: Bundle.main.resourceURL!, texturesNamed: atlasName).first?.value
    let characterCount = Int((try sourceTexture?.sizeF().y ?? .zero) / size.y)
    
    var characterAnimations = [[Texture]]()
    for index in 0..<characterCount {
        let position = (x: size.x, y: size.y * Float(index))
        print(position)
        var frameCount = 8
        switch index {
        case 0: fallthrough
        case 3: frameCount = 4
        default: ()
        }
        let textures = try Texture.separateTextures(from: sourceTexture, frameCount: frameCount, format: format, sized: size, locatedAt: position, into: renderer, resourceURL: sourceURL)
        characterAnimations.append(textures)
    }
    
    return characterAnimations
}

if #available(OSX 10.12, *) {
    // Initialize the game (and SDL, too) --------------------------------------
    let game = Game(loopFrequency: 1/60)
    try game.initialize()
    
    // Prints display mode information -----------------------------------------
    Display.allDisplays.forEach {
        print("Display:", String(cString: SDL_GetDisplayName($0.id)).uppercased())
        $0.modes().forEach {
            print("""
                .: Display Size: \($0.w) x \($0.h)
                .: Pixel Format: \(PixelFormat.name(for: $0.format))
                .: Refresh Rate: \($0.refresh_rate)hz
                -----------------------------------------
                """)
        }
    }
    
    // Create a window scene and renderer to draw into -------------------------
    let mainScene = try MainScene(window: (title: "DemoSDL2", width: 480, height: 640), windowFlags: .allowHighDPI, renderFlags: [.targetTexturing, .verticalSync])
    let  renderer = mainScene.renderer

    // Print render info -------------------------------------------------------
    print(try renderer!.info())
    
    // Create a game board to be renderered into our scene ---------------------
    let gridValues    = Grid<Piece.Element>(rows: 17, columns: 15)
    let gameBoard     = GameBoard(gridValues)
    let blockTexture  = try Texture.load(into: renderer, resourceURL: Bundle.main.resourceURL!, texturesNamed: "block.png")
    let boardRenderer = try GameBoardRenderer(tileTexture: blockTexture["block.png"], gameBoard: gameBoard)

    // Modify game board state on a set interval -------------------------------
    let stateChangeAction = Action(repeats: true, atInterval: 0.1) { deltaTime in
        boardRenderer.testStateChange(numberOfTile: 100)
    }
    mainScene.attach(actions: stateChangeAction)
    mainScene.enableUpdateIntervalLogging = false

    // Include the game board renderer in the scene's node graph ---------------
    mainScene.gameBoardRenderer = boardRenderer
    
    // Character Animation -----------------------------------------------------
    let allCharacterTextures = try LoadCharacterSprites(format: mainScene.window.pass(to: SDL_GetWindowPixelFormat), into: renderer, atlasName: "characters_7.png")
    for (index, characterTextures) in allCharacterTextures.enumerated() {
        let characterNode      = SpriteNode(texture: characterTextures.first, scaledTo: 6.0)
        let characterAnimation = AnimateTexture(spriteNode: characterNode, textures: characterTextures, atInterval: 0.25)
        
        mainScene.attach(actions: characterAnimation)
        mainScene.add(child: characterNode)
        
        if index == 2 {
            characterNode.isFlipped.toggle()
        }
        characterNode.moveTo(x: Int(characterNode.size.x * characterNode.scale) * index + 64 + (32 * index), y: 1064)()
    }

    // Present the game's current scene ----------------------------------------
    try game.present(scene: mainScene)

    // Start the game ----------------------------------------------------------
    game.start()
}
