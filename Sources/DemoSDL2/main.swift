import Foundation
import Metal
import Quartz
import CSDL2
import CSDL2_Image
import SwiftSDL2

//--------------------------------------------------------------------------
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

if #available(OSX 10.12, *) {
    let game = Game(loopFrequency: 1/60)
    try game.initialize()
    
    //--------------------------------------------------------------------------
    let mainScene = try MainScene(window: (title: "Swiftris", width: 480, height: 640), windowFlags: .allowHighDPI)
    let  renderer = mainScene.renderer

    //--------------------------------------------------------------------------
    print(try renderer!.info())
    
    //--------------------------------------------------------------------------
    let gridValues    = Grid<Piece.Element>(rows: 20, columns: 15)
    let gameBoard     = GameBoard(gridValues)
    let blockTexture  = try Texture.load(into: renderer, resourceURL: Bundle.main.resourceURL!, texturesNamed: "block.png", "characters_7.png")
    let boardRenderer = try GameBoardRenderer(tileTexture: blockTexture["block.png"], gameBoard: gameBoard)
    
    //--------------------------------------------------------------------------
    let stateChangeAction = Action(repeats: true, atInterval: 0.1) { deltaTime in
        boardRenderer.testStateChange(numberOfTile: 100)
    }
    mainScene.attach(actions: stateChangeAction)
    mainScene.enableUpdateIntervalLogging = false

    //--------------------------------------------------------------------------
    mainScene.gameBoardRenderer = boardRenderer
    
    //--------------------------------------------------------------------------
    try game.present(scene: mainScene)
    
    //--------------------------------------------------------------------------
    game.start()
}
