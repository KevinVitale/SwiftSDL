import Clibsdl2

@discardableResult
func InitializeSDL(flags: UInt32...) -> Int32 {
    return SDL_Init(flags.reduce(0) { $0 | $1 })
}
//------------------------------------------------------------------------------

@discardableResult
func InitializeImage(flags: IMG_InitFlags...) -> Int32 {
    return IMG_Init(flags.reduce(0) { $0 | Int32($1.rawValue) })
}
//------------------------------------------------------------------------------

func Run(renderer: Renderer, while handler: (SDL_Event) throws -> Bool) rethrows -> Never {
    var running = true
    var event   = SDL_Event()

    let image   = Load(image: "/Users/kevin/Desktop/block_deux.png")
    let texture = SDL_CreateTextureFromSurface(renderer.pointer, image)
    SDL_FreeSurface(image)

    while running {
        while SDL_PollEvent(&event) != 0 {
            guard try handler(event) else {
                running = false
                break;
            }
        }
        
        renderer.drawingColor = .init()
        renderer.clear()

        SDL_SetTextureColorMod(texture, renderer.drawingColor.r, renderer.drawingColor.g, renderer.drawingColor.b)

        let rows = 20
        let cols = 10
        for r in 0..<rows {
            for c in 0..<cols {
                let color = SDL_Color.random()
                SDL_SetTextureColorMod(texture, color.r, color.g, color.b)
                
                var dstrect = SDL_Rect(x: Int32(c * 32), y: Int32(r * 32), w: 32, h: 32)
                _ = SDL_RenderCopyEx(renderer.pointer, texture, nil, &dstrect, 0, nil, SDL_FLIP_NONE)
            }
        }
        renderer.present()
        SDL_Delay(25)
    }

    SDL_DestroyTexture(texture)
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

Drivers().forEach {
    let name = String(cString: $0.name).uppercased()
    print("\(name)", terminator: "\n\t")
    print("Accl:\t\t \($0.has(flags: SDL_RENDERER_ACCELERATED))", terminator: "\n\t")
    print("Software:\t \($0.has(flags: SDL_RENDERER_SOFTWARE))", terminator: "\n\t")
    print("Texture:\t \($0.has(flags: SDL_RENDERER_TARGETTEXTURE))", terminator: "\n\t")
    print("VSync:\t\t \($0.has(flags: SDL_RENDERER_PRESENTVSYNC))", terminator: "\n\t")
    print("\n")
}

let window = Window(title: "Swift SDL", width: 480, height: 640)!
let render = Renderer(window: window, flags: SDL_RENDERER_ACCELERATED, SDL_RENDERER_PRESENTVSYNC)!

Run(renderer: render) {
    $0.type != SDL_QUIT.rawValue
}

