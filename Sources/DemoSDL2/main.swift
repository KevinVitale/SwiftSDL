import Foundation
import Metal
import Quartz
import CSDL2
import CSDL2_Image
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
                .: Pixel Format: \(PixelFormat.name(for: $0.format))
                .: Refresh Rate: \($0.refresh_rate)hz
                -----------------------------------------
                """)
        }
    }
    
    // Create a window scene and renderer to draw into -------------------------
    let mainScene = try MainScene(window: (title: "DemoSDL2", width: 480, height: 640), windowFlags: .allowHighDPI)
    let  renderer = mainScene.renderer

    // Print render info -------------------------------------------------------
    print(try renderer!.info())

    // Create a game board to be renderered into our scene ---------------------
    let gridValues    = Grid<Piece.Element>(rows: 20, columns: 15)
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
    
    // Present the game's current scene ----------------------------------------
    try game.present(scene: mainScene)
    
    // Start the game ----------------------------------------------------------
    game.start()
}
