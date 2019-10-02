import Foundation.NSBundle
import CSDL2
import SwiftSDL2

try SDL.initialize(subSystems: .everything)

var characterIndex: Int32 = 1
var turnOnBlinking = false
var clearRenderTarget = true
var fillRect = SDL_Rect(x: 200, y: 400, w: 100, h: 100)


var yPos = 0
var xPos = 0
var flip = false
var angle: Double = 0

/* Hack cause this is CLI program. Needs fixin' */
guard let projectURL = Bundle.main.resourceURL else {
    fatalError()
}


var characterSprites: Texture! = nil
var itemSprites: Texture! = nil

print(SDL.Version.current)

func Run(renderer: inout Renderer, while handler: (SDL_Event) throws -> Bool) rethrows -> Never {
    var running = true
    var event   = SDL_Event()
    
    if characterSprites == nil {
        switch Result(catching: { try Texture(renderer: renderer, pathURL: URL(fileURLWithPath: "characters_7.png", relativeTo: projectURL)) }) {
        case .success(let texture):
            characterSprites = texture
        case .failure(let error):
            fatalError("Missing texture: \(error)")
        }
    }
    
    if itemSprites == nil {
        switch Result(catching: { try Texture(renderer: renderer, pathURL: URL(fileURLWithPath: "spritesheet.png", relativeTo: projectURL)) }) {
        case .success(let texture):
            itemSprites = texture
        case .failure(let error):
            fatalError("Missing texture: \(error)")
        }
    }
    
    let frames = 4
    let offset = 0
    var index  = offset

    while running {
        while SDL_PollEvent(&event) != 0 {
            guard try handler(event) else {
                running = false
                break;
            }
        }
        
        let drawingColor: SDL_Color = .init(r: 255, g: 255, b: 255, a: 255)
        if clearRenderTarget {
            renderer.setDrawingColor(with: drawingColor)
            renderer.clear()
        }

        if turnOnBlinking == true {
            characterSprites.setColorMod(with: .random())
        }
        else {
            characterSprites.setColorMod(with: drawingColor)
        }

        let k = Int32(16)
        let row: Int32 = (characterIndex - 1)
        let srcrect = SDL_Rect(x: Int32(index * 32), y: 32 * row, w: k * 2, h: k * 2)
        let dstrect = SDL_Rect(x: Int32(xPos), y: Int32(yPos), w: k * 4, h: k * 4)
        
        var doFlip: Renderer.Flip = .none
        if flip {
            doFlip = .horizontal
        }
        renderer.copy(from: characterSprites, from: srcrect, to: dstrect, rotatedBy: angle, flipped: doFlip)

        index += 1
        if index >= frames + offset {
            index = offset
        }

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

        renderer.present()
        SDL_Delay(100)
    }

    SDL.quit(subSystem: .everything)
    exit(0)
}

Renderer.availableRenderers.forEach { driver in
    let name = String(cString: driver.name).uppercased()
    print("\(name)", terminator: "\n\t")
    print("Accl:\t\t \(driver.has(flags: .hardwareAcceleration))", terminator: "\n\t")
    print("Software:\t \(driver.has(flags: .softwareRendering))", terminator: "\n\t")
    print("Texture:\t \(driver.has(flags: .targetTexturing))", terminator: "\n\t")
    print("VSync:\t\t \(driver.has(flags: .verticalSync))", terminator: "\n\t")
    print("\n")
}

let window = try Window(title: "Swift SDL", width: 480, height: 640)
var render = try Renderer(window: window, driver: 3)
let surface = try window.surface.get()

if let metalLayer = render.metalLayer, let device = metalLayer.device
{
    print(device.name)
}

try Run(renderer: &render) {
    if $0.type == SDL_KEYDOWN.rawValue {
        switch Int($0.key.keysym.sym) {
        case SDLK_1: characterIndex = 1
        case SDLK_2: characterIndex = 2
        case SDLK_3: characterIndex = 3
        case SDLK_4: characterIndex = 4
        case SDLK_f:
            clearRenderTarget = false
            try surface.fill(rects: fillRect, color: .random())
        case SDLK_c:
            clearRenderTarget = true
            try surface.fill(color: SDL_Color(r: 255, g: 255, b: 255, a: 255))
            
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

