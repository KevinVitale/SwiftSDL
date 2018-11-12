import Clibsdl2


// InitializeSDL(flags: SDL_INIT_VIDEO)
// InitializeImage(flags: IMG_INIT_PNG)


var yPos = 0
var xPos = 0
var flip = false

func Run(renderer: Renderer, while handler: (SDL_Event) throws -> Bool) rethrows -> Never {
    var running = true
    var event   = SDL_Event()

    let image = Texture(renderer: renderer, file: "/Users/kevin/Desktop/characters_7.png")!
    let texture = image.pointer
    
    let atlas = Texture(renderer: renderer, file: "/Users/kevin/Desktop/spritesheet.png")!
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
        
        renderer.draw(.point(.init(x: 100, y: 100)))
        
        /*
        let color = SDL_Color.random()
        SDL_SetTextureColorMod(texture, color.r, color.g, color.b)
         */
        
        /*
        var srcrect = SDL_Rect(x: Int32(xPos), y: Int32(yPos), w: 32, h: 32)
        var dstrect = SDL_Rect(x: Int32(xPos), y: Int32(yPos), w: 32, h: 32)
        _ = SDL_RenderCopyEx(renderer.pointer, texture, &srcrect, &dstrect, 0, nil, SDL_FLIP_NONE)
        
        if xPos > renderer.outputtedSize.width {
            xPos = -32
        }
        if yPos > renderer.outputtedSize.height {
            yPos = -32
        }
         */
        
        let k = Int32(16)
        var srcrect = SDL_Rect(x: Int32(index * 32), y: 32, w: k * 2, h: k * 2)
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
        SDL_Delay(100)
    }

    exit(0)
}
//------------------------------------------------------------------------------

func Drivers() -> [SDL_RendererInfo] {
    return (0..<Renderer.driverCount).compactMap { Renderer.driverInfo($0) }
}
//------------------------------------------------------------------------------

func Load(image path: String) -> UnsafeMutablePointer<SDL_Surface>! {
    return path.withCString { IMG_Load($0) }
}
//------------------------------------------------------------------------------

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
let render = Renderer(window: window)!

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
