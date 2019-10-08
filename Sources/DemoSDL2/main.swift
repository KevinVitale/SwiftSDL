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
        default: ()
        }
    }
    return event.type != SDL_QUIT.rawValue
}

func Draw(to renderer: Renderer?) throws {
    defer {
        renderer?.pass(to: SDL_RenderPresent)
    }
    
    let whiteColor = SDL_Color(r: 255, g: 255, b: 255, a: 255)
    try renderer?.result(of: SDL_SetRenderDrawColor, whiteColor.r, whiteColor.g, whiteColor.b, whiteColor.a).get()
    try renderer?.result(of: SDL_RenderClear).get()
    
    //--------------------------------------------------------------------------
    let size: Int32 = 16
    let rows: Int32 = 20
    let cols: Int32 = 10
    for r in 0..<rows {
        for c in 0..<cols {
            let randomColor = SDL_Color.random()
            textures.last?.pass(to: SDL_SetTextureColorMod, randomColor.r, randomColor.g, randomColor.b)

            let srcrect = SDL_Rect(x: c * size, y: r * size, w: size, h: size)
            let dstrect = SDL_Rect(x: c * size, y: r * size, w: size, h: size)
            renderer?.copy(from: textures.last, from: srcrect, to: dstrect)
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


/*
var characterIndex: Int32 = 1
var turnOnBlinking = false
var clearRenderTarget = true
var fillRect = SDL_Rect(x: 200, y: 400, w: 100, h: 100)
var isLoadingTexture = false


var yPos = 0
var xPos = 0
var flip = false
var angle: Double = 0

/* Hack cause this is CLI program. Needs fixin' */
guard let projectURL = Bundle.main.resourceURL else {
    fatalError()
}

print(projectURL)
 */

// var characterSprites: SDL.Texture! = nil
// /*weak*/ var itemSprites: SDL.Texture! = nil

// print(SDL.Version.current)

/*
let textureLoadQueue = DispatchQueue(label: "com.demo.sdl2.texture.loading.queue", attributes: [.concurrent])

func Run(needsDisplay shouldRender: @autoclosure () -> Bool, renderer: inout SDL.Renderer!, while handler: (SDL_Event) throws -> Bool) rethrows -> Never {
    var running = true
    var event   = SDL_Event()
    
    let frames = 4
    let offset = 0
    var index  = offset

    while running {
        if characterSprites == nil {
            textureLoadQueue.async { [renderer] in
                if #available(macOS 10.11, *), DispatchQueue.main.sync(execute: { isLoadingTexture == false }) {
                    DispatchQueue.main.sync(execute: { isLoadingTexture = true })
                    switch Result(catching: { try SDL.Texture(renderer: renderer!, pathURL: URL(fileURLWithPath: "characters_7.png", relativeTo: projectURL)) }) {
                    case .success(let texture):
                        characterSprites = texture
                        DispatchQueue.main.sync(execute: {
                            isLoadingTexture = false
                            print("Texture loaded...")
                        })
                    case .failure(let error):
                        fatalError("Missing texture: \(error)")
                    }
                }
            }
        }

        if itemSprites == nil {
            textureLoadQueue.async { [renderer] in
                if #available(macOS 10.11, *), DispatchQueue.main.sync(execute: { isLoadingTexture == false }) {
                    DispatchQueue.main.sync(execute: { isLoadingTexture = true })
                    switch Result(catching: { try SDL.Texture(renderer: renderer!, pathURL: URL(fileURLWithPath: "spritesheet.png", relativeTo: projectURL)) }) {
                    case .success(let texture):
                        itemSprites = texture
                        DispatchQueue.main.sync(execute: {
                            isLoadingTexture = false
                            print("Texture loaded...")
                        })
                    case .failure(let error):
                        fatalError("Missing texture: \(error)")
                    }
                }
            }
        }

        while SDL_PollEvent(&event) != 0 {
            guard try handler(event) else {
                running = false
                break;
            }
        }
        
        if shouldRender() {
            let drawingColor: SDL_Color = .init(r: 255, g: 255, b: 255, a: 255)
            if clearRenderTarget {
                renderer.setDrawingColor(with: drawingColor)
                renderer.clear()
            }

            let k = Int32(16)
            if let characterSprites = characterSprites {
                if turnOnBlinking == true {
                    characterSprites.setColorMod(with: .random())
                }
                else {
                    characterSprites.setColorMod(with: drawingColor)
                }
                
                let row: Int32 = (characterIndex - 1)
                let srcrect = SDL_Rect(x: Int32(index * 32), y: 32 * row, w: k * 2, h: k * 2)
                let dstrect = SDL_Rect(x: Int32(xPos), y: Int32(yPos), w: k * 4, h: k * 4)
                
                var doFlip: SDL.Renderer.Flip = .none
                if flip {
                    doFlip = .horizontal
                }
                renderer.copy(from: characterSprites, from: srcrect, to: dstrect, rotatedBy: angle, flipped: doFlip)
                
                index += 1
                if index >= frames + offset {
                    index = offset
                }
            }
            if let itemSprites = itemSprites {
                let rows = 20
                let cols = 10
                for r in 0..<rows {
                    for c in 0..<cols {
                        itemSprites.setColorMod(with: .random())
                        
                        let srcrect = SDL_Rect(x: Int32(c) * k, y: Int32(r) * k, w: k, h: k)
                        let dstrect = SDL_Rect(x: Int32(c) * k, y: Int32(r) * k, w: k, h: k)
                        renderer.copy(from: itemSprites, from: srcrect, to: dstrect)
                    }
                }
            }

            renderer.present()
        }
        SDL_Delay(100)
    }

    renderer = nil
    SDL.Quit(subSystems: .everything)
    exit(0)
}

SDL.Renderer.renderers().forEach {
    print("------------------------------------------------------------|")
    print($0)
    print("------------------------------------------------------------|")
}

var renderer: SDL.Renderer! = nil
let window  = try SDL.Window(title: "Swift SDL", renderer: &renderer, width: 480, height: 640)
let surface = try? window.surface.get()
window.title += " – Renderer: \(renderer.name.capitalized)"

if #available(macOS 10.11, *), let metalLayer = renderer.metalLayer {
    window.title += " (\(metalLayer.device!.name))"
}

try Run(needsDisplay: true, renderer: &renderer) {
    if $0.type == SDL_KEYDOWN.rawValue {
        switch Int($0.key.keysym.sym) {
        case SDLK_1: characterIndex = 1
        case SDLK_2: characterIndex = 2
        case SDLK_3: characterIndex = 3
        case SDLK_4: characterIndex = 4
        case SDLK_f:
            clearRenderTarget = false
            try surface?.fill(rects: fillRect, color: .random())
        case SDLK_c:
            clearRenderTarget = true
            try surface?.fill(color: SDL_Color(r: 255, g: 255, b: 255, a: 255))
            
        case SDLK_RETURN: turnOnBlinking = !turnOnBlinking
        case SDLK_RIGHT:
            if flip == false {
                xPos += 32
            }
            flip = false
        case SDLK_LEFT:
            if flip == true {
                xPos -= 32
            }
            flip = true
        case SDLK_DOWN: yPos += 32
        case SDLK_UP: yPos -= 32
        case SDLK_SPACE:
            yPos = 0; xPos = 0
        default: ()
        }
    }

    return $0.type != SDL_QUIT.rawValue
}
*/
