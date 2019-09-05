import Clibsdl2
import Foundation
import Quartz

// InitializeSDL(flags: SDL_INIT_VIDEO)
// InitializeImage(flags: IMG_INIT_PNG)

var yPos = 0
var xPos = 0
var flip = false

/* Hack cause this is CLI program. Needs fixin' */
guard let path = CommandLine.arguments.last
    , let url = URL(string: path) else {
        fatalError()
}



var version: SDL_version = SDL_version()
SDL_GetVersion(&version)
print(version)

func Run(renderer: Renderer, while handler: (SDL_Event) throws -> Bool) rethrows -> Never {
    var running = true
    var event   = SDL_Event()
    
    guard let image = Texture(renderer: renderer, file: url.appendingPathComponent("characters_7.png").absoluteString) else {
        fatalError("Missing texture")
    }
    let texture = image.pointer
    
    guard let atlas = Texture(renderer: renderer, file: url.appendingPathComponent("spritesheet.png").absoluteString) else {
        fatalError("Missing texture")
    }
    let spirtes = atlas.pointer

    
    let frames = 4
    // let offset = 18
    let offset = 0
    var index = offset

    while running {
        while SDL_PollEvent(&event) != 0 {
            guard try handler(event) else {
                running = false
                break;
            }
        }
        
        renderer.drawingColor = SDL_Color(r: 255, g: 255, b: 255, a: 255)
        renderer.clear()
        SDL_SetTextureColorMod(texture, renderer.drawingColor.r, renderer.drawingColor.g, renderer.drawingColor.b)

        let k = Int32(16)
        let row: Int32 = 3
        var srcrect = SDL_Rect(x: Int32(index * 32), y: 32 * row, w: k * 2, h: k * 2)
        var dstrect = SDL_Rect(x: Int32(xPos), y: Int32(yPos), w: k * 4, h: k * 4)
        
        var doFlip = SDL_FLIP_NONE
        if flip {
            doFlip = SDL_FLIP_HORIZONTAL
        }
        _ = SDL_RenderCopyEx(renderer.pointer, texture, &srcrect, &dstrect, 0, nil, doFlip)
        index += 1
        if index >= frames + offset {
            index = offset
        }

        let rows = 20
        let cols = 10
        for r in 0..<rows {
            for c in 0..<cols {
                let color = SDL_Color.random()
                SDL_SetTextureColorMod(texture, color.r, color.g, color.b)
                
                var srcrect = SDL_Rect(x: Int32(c) * k, y: Int32(r) * k, w: k, h: k)
                var dstrect = SDL_Rect(x: Int32(c) * k, y: Int32(r) * k, w: k, h: k)
                _ = SDL_RenderCopyEx(renderer.pointer, spirtes, &srcrect, &dstrect, 0, nil, SDL_FLIP_NONE)
            }
        }

        renderer.present()
        // SDL_Delay(100)
        
        if let metalLayer = renderer.metalLayer
            , let device = metalLayer.device {
            print(device.name)
        }
    }

    exit(0)
}

func Load(image path: String) -> UnsafeMutablePointer<SDL_Surface>! {
    return path.withCString { IMG_Load($0) }
}

Drivers().forEach { driver in
    let name = String(cString: driver.name).uppercased()
    print("\(name)", terminator: "\n\t")
    print("Accl:\t\t \(driver.has(flags: SDL_RENDERER_ACCELERATED))", terminator: "\n\t")
    print("Software:\t \(driver.has(flags: SDL_RENDERER_SOFTWARE))", terminator: "\n\t")
    print("Texture:\t \(driver.has(flags: SDL_RENDERER_TARGETTEXTURE))", terminator: "\n\t")
    print("VSync:\t\t \(driver.has(flags: SDL_RENDERER_PRESENTVSYNC))", terminator: "\n\t")
    print("\n")
}

let window = Window(title: "Swift SDL", width: 480, height: 640)!
let render = Renderer(window: window, driver: 0)!


Run(renderer: render) {
    if $0.type == SDL_KEYDOWN.rawValue {
        flip = false
        switch Int($0.key.keysym.sym) {
        case SDLK_RIGHT: xPos += 32
        case SDLK_LEFT:
            xPos -= 32
            flip = true
        case SDLK_DOWN: yPos += 32
        case SDLK_UP: yPos -= 32
        default: ()
        }
    }

    return $0.type != SDL_QUIT.rawValue
}

