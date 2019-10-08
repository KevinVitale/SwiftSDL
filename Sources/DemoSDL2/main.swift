import Foundation
import Metal
import Quartz
import CSDL2
import CSDL2_Image
import SwiftSDL2

//------------------------------------------------------------------------------
public extension SDL_Color {
    static func random(alpha a: UInt8 = 0xFF) -> SDL_Color {
        let r = UInt8(arc4random_uniform(256))
        let g = UInt8(arc4random_uniform(256))
        let b = UInt8(arc4random_uniform(256))
        return SDL_Color(r: r, g: g, b: b, a: a)
    }
    
    func mapRGB(format: UnsafeMutablePointer<SDL_PixelFormat>!) -> UInt32 {
        return SDL_MapRGB(format, self.r, self.g, self.b)
    }
    
    func mapRGBA(format: UnsafeMutablePointer<SDL_PixelFormat>!) -> UInt32 {
        return SDL_MapRGBA(format, self.r, self.g, self.b, self.a)
    }
}

//------------------------------------------------------------------------------
try SDL.Init(subSystems: .everything)

//------------------------------------------------------------------------------
var characterAnimation = [ /* Quick & Dirty (TM) */
    "currentFrame"      : 0, // Read-write
    "frameCount"        : 4, // Read-only
    "frameStartingAt"   : 0, // Read-only
    "isBlinking"        : 0, // Read-write
    "isFlipped"         : 0, // Read-write
    "selectedCharacter" : 0, // Read-write
    "spriteSize"        : 32 // Read-only
]
characterAnimation["currentFrame"]! = characterAnimation["frameStartingAt"]!

var characterPosition: (x: Int32, y: Int32) = (0, 0)
var showSpriteSheet = false

//------------------------------------------------------------------------------
let window   = try Window(title: "SwiftSDL", width: 640, height: 480)
let renderer = window
    .pass(to: SDL_CreateRenderer, -1, .renderFlags(.verticalSync))
    .map(Renderer.init)

//------------------------------------------------------------------------------
let resourceURL = Bundle.main.resourceURL!
let textures = [ "characters_7.png", "spritesheet.png" ]
    .compactMap { resourceURL.appendingPathComponent($0) }
    .compactMap { renderer?.pass(to: IMG_LoadTexture, $0.path) }
    .map(Texture.init)

//------------------------------------------------------------------------------
func HandleInput(_ event: SDL_Event) throws -> Bool {
    if event.type == SDL_KEYDOWN.rawValue {
        switch Int(event.key.keysym.sym) {
        case SDLK_1: characterAnimation["selectedCharacter"] = 0
        case SDLK_2: characterAnimation["selectedCharacter"] = 1
        case SDLK_3: characterAnimation["selectedCharacter"] = 2
        case SDLK_4: characterAnimation["selectedCharacter"] = 3
        case SDLK_s: showSpriteSheet.toggle()
        case SDLK_RETURN:
            let isBlinking = characterAnimation["isBlinking"]!
            characterAnimation["isBlinking"]! = isBlinking == 0 ? 1 : 0
        case SDLK_RIGHT:
            if characterAnimation["isFlipped"]! == 0 {
                characterPosition.x += Int32(characterAnimation["spriteSize"]!)
            }
            characterAnimation["isFlipped"]! = 0
        case SDLK_LEFT:
            if characterAnimation["isFlipped"]! == 1 {
                characterPosition.x -= Int32(characterAnimation["spriteSize"]!)
            }
            characterAnimation["isFlipped"]! = 1
        case SDLK_DOWN:
            characterPosition.y += Int32(characterAnimation["spriteSize"]!)
        case SDLK_UP:
            characterPosition.y -= Int32(characterAnimation["spriteSize"]!)
        case SDLK_SPACE:
            characterPosition = (x: 0, y: 0)
        default: ()
        }
    }
    
    return event.type != SDL_QUIT.rawValue
}

func Draw(to renderer: Renderer?) throws {
    defer {
        renderer?.pass(to: SDL_RenderPresent)
    }
    
    //--------------------------------------------------------------------------
    let whiteColor = SDL_Color(r: 255, g: 255, b: 255, a: 255)
    try renderer?.result(of: SDL_SetRenderDrawColor, whiteColor.r, whiteColor.g, whiteColor.b, whiteColor.a).get()
    try renderer?.result(of: SDL_RenderClear).get()
    
    //--------------------------------------------------------------------------
    if characterAnimation["isBlinking"] == 1 {
        let randomColor = SDL_Color.random()
        textures.first?.result(of: SDL_SetTextureColorMod, randomColor.r, randomColor.g, randomColor.b)
    } else {
        textures.first?.result(of: SDL_SetTextureColorMod, 255, 255, 255)
    }

    let spriteSize    = Int32(characterAnimation["spriteSize"]!)
    let selectedIndex = Int32(characterAnimation["selectedCharacter"]!)
    let currentFrame  = Int32(characterAnimation["currentFrame"]!)
    let srcrect       = SDL_Rect(x: currentFrame * spriteSize, y: spriteSize * selectedIndex, w: spriteSize, h: spriteSize)
    let dstrect       = SDL_Rect(x: characterPosition.x, y: characterPosition.y, w: spriteSize * 2, h: spriteSize * 2)
    let isFlipped     = characterAnimation["isFlipped"]! == 1 ? Renderer.RenderFlip.horizontal : Renderer.RenderFlip.none
    
    renderer?.copy(texture: textures.first!, from: srcrect, into: dstrect, flipped: isFlipped)
    
    characterAnimation["currentFrame"]! += 1
    if characterAnimation["currentFrame"]! >= characterAnimation["frameCount"]! + characterAnimation["frameStartingAt"]! {
        characterAnimation["currentFrame"]! = characterAnimation["frameStartingAt"]!
    }

    //--------------------------------------------------------------------------
    guard showSpriteSheet else {
        return
    }
    let size: Int32 = 16
    let rows: Int32 = 13 * 2
    let cols: Int32 = 16 * 2
    for r in 0..<rows {
        for c in 0..<cols {
            let randomColor = SDL_Color.random()
            textures.last?.result(of: SDL_SetTextureColorMod, randomColor.r, randomColor.g, randomColor.b)

            let srcrect = SDL_Rect(x: c * size, y: r * size, w: size, h: size)
            let dstrect = SDL_Rect(x: c * size, y: r * size, w: size, h: size)
            renderer?.copy(texture: textures.last, from: srcrect, into: dstrect)
        }
    }
}

//------------------------------------------------------------------------------
var running = true
repeat {
    var event = SDL_Event()
    while SDL_PollEvent(&event) != 0 {
        guard try HandleInput(event) else {
            running = false
            break
        }
    }
    
    try Draw(to: renderer)
    SDL_Delay(100)
} while running

//------------------------------------------------------------------------------
SDL.Quit(subSystems: .everything)
exit(0)
