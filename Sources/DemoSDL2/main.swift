import Foundation
import CSDL2
import SwiftSDL2

try SDL.Run { engine in
    // Start engine ------------------------------------------------------------
    try engine.start(subsystems: .everything)
    
    // Print display modes -----------------------------------------------------
    for display in engine.videoDisplays {
        print("---------------------------------------------|")
        print(display.name)
        print("---------------------------------------------|")
        for mode in display.modes() {
            print("\(mode.w) x \(mode.h)\t", SDLPixelFormat.name(for: mode.format), "\t\(mode.refresh_rate)hz")
        }
        print("---------------------------------------------|")
    }
    
    // Create a renderer to draw into -------------------------
    let (window, renderer) = try engine.addWindow(title: "DemoSDL2", width: 480, height: 640, windowFlags: .allowHighDPI, renderFlags: [.targetTexturing, .verticalSync])
    let mainScene = Scene(backgroundColor: SDL_Color(r: 255, g: 255, b: 255, a: 255))
    
    // Print render info -------------------------------------------------------
    print(try renderer.info.get())
    
    // Create a game board to be renderered into our scene ---------------------
    let gridValues    = Grid<Piece.Element>(rows: 17, columns: 15)
    let gameBoard     = GameBoard(gridValues)
    let blockTexture  = try SDLTexture.load(into: renderer, resourceURL: Bundle.main.resourceURL!, texturesNamed: "block.png")
    let boardRenderer = try GameBoardRenderer(tileTexture: blockTexture["block.png"], gameBoard: gameBoard)

    // Modify game board state on a set interval -------------------------------
    boardRenderer.run(Action
        .customAction(duration: 0.1) { _, _ in boardRenderer.testStateChange(numberOfTile: 100) }
        .map(Action.repeatsForever(_:))
    )

    // Include the game board renderer in the scene's node graph ---------------
    mainScene.add(child: boardRenderer)

    // Character (Sprite) Animation --------------------------------------------
    let windowPixelFormat    = window.pass(to: SDL_GetWindowPixelFormat)
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
    
    // Handle input ------------------------------------------------------------
    engine.handleInput = { [weak engine] in
        var event = SDL_Event()
        while(SDL_PollEvent(&event) != 0) {
            if event.type == SDL_QUIT.rawValue {
                engine?.stop()
            }
        }
    }
    
    // Update 'scene' ----------------------------------------------------------
    engine.update = { deltaTime in
        mainScene.update(atTime: deltaTime)
    }
    
    // Render 'scene' ----------------------------------------------------------
    engine.render = {
        mainScene.draw(renderer: renderer)
    }
}
