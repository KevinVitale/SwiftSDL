import Foundation
import CSDL2
import SwiftSDL2

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
                .: Pixel Format: \(SDLPixelFormat.name(for: $0.format))
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
    let blockTexture  = try SDLTexture.load(into: renderer, resourceURL: Bundle.main.resourceURL!, texturesNamed: "block.png")
    let boardRenderer = try GameBoardRenderer(tileTexture: blockTexture["block.png"], gameBoard: gameBoard)

    // Modify game board state on a set interval -------------------------------
    let stateChangeAction = Action
        .customAction(duration: 0.1) { _, _ in boardRenderer.testStateChange(numberOfTile: 100) }
        .map(Action.repeatsForever(_:))
    
    mainScene.run(stateChangeAction)

    // Include the game board renderer in the scene's node graph ---------------
    mainScene.gameBoardRenderer = boardRenderer
    
    // Character Animation -----------------------------------------------------
    let windowPixelFormat    = mainScene.window.pass(to: SDL_GetWindowPixelFormat)
    let allCharacterTextures = try CharacterSprites.load(format: windowPixelFormat
        , into: renderer
        , atlasName: "characters_7.png"
    )
    
    for (index, characterTextures) in allCharacterTextures.enumerated() {
        let characterNode = SpriteNode(texture: characterTextures.first, scaledTo: 6.0)
        
        // Move to point -------------------------------------------------------
        let xPos = Int(characterNode.size.x * characterNode.scale) * index + 64 + (32 * index)
        let yPos = 1064
        characterNode.moveTo(x: xPos, y: yPos)()
        
        // Flip viewing direction ----------------------------------------------
        if index >= 2 {
            characterNode.isFlipped.toggle()
        }
        
        // Add animation actions -----------------------------------------------
        characterNode.run(Action
            .animate(characterTextures, frameDuration: 0.25)
            .map(Action.repeatsForever(_:))
        )

        // Add to node parent --------------------------------------------------
        mainScene.add(child: characterNode)
    }

    // Present the game's current scene ----------------------------------------
    try game.present(scene: mainScene)

    // Start the game ----------------------------------------------------------
    game.start()
}
