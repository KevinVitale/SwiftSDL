import Clibsdl2

@discardableResult
func Initialize(flags: UInt32...) -> Int32 {
    return SDL_Init(flags.reduce(0) { $0 | $1 })
}

func Run(renderer: Renderer, while handler: (SDL_Event) throws -> Bool) rethrows -> Never {
    var running = true
    var event   = SDL_Event()
    while running {
        while SDL_PollEvent(&event) != 0 {
            guard try handler(event) else {
                running = false
                break;
            }
        }
        
        renderer.drawingColor = .random()
        renderer.clear()
        renderer.present()
    }
    
    SDL_Quit()
    exit(0)
}

func Drivers() -> [SDL_RendererInfo] {
    return (0..<Renderer.driverCount).compactMap { Renderer.driverInfo($0) }
}

/* Initialize */
Initialize(flags: SDL_INIT_VIDEO)

Drivers().forEach {
    let name = String(cString: $0.name).uppercased()
    print("\(name)", terminator: "\n\t")
    print("Accl:\t\t \($0.has(flags: SDL_RENDERER_ACCELERATED))", terminator: "\n\t")
    print("Software:\t \($0.has(flags: SDL_RENDERER_SOFTWARE))", terminator: "\n\t")
    print("Texture:\t \($0.has(flags: SDL_RENDERER_TARGETTEXTURE))", terminator: "\n\t")
    print("VSync:\t\t \($0.has(flags: SDL_RENDERER_PRESENTVSYNC))", terminator: "\n\t")
    print("\n")
}

let window = Window(title: "Swift SDL", width: 480, height: 640, flags: SDL_WINDOW_SHOWN)!
let render = Renderer(window: window, flags: SDL_RENDERER_PRESENTVSYNC)!

Run(renderer: render) {
    $0.type != SDL_QUIT.rawValue
}

