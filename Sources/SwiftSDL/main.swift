import Clibsdl2
import Dispatch

class App {
    func run() {
        let (window, renderer) = initialize();
        defer { SDL_Quit() }
        
        window.title = "Owen's Robo-cutioner"
        window.resizable = true

        var running     = true
        var event       = SDL_Event()

        while running {
            /* Process Input */
            while SDL_PollEvent(&event) != 0 {
                handle(event: event)
                guard event.type != SDL_QUIT.rawValue else {
                    running = false
                    break
                }
            }

            /* Update Logic */
            update()

            /* Render Graphics */
            render(renderer)
        }
    }
    
    private func initialize() -> (window: Window, renderer: Renderer) {
        guard SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER) >= 0 else {
            fatalError()
        }
        
        var renderer: OpaquePointer? = nil
        var window: OpaquePointer? = nil
        
        guard SDL_CreateWindowAndRenderer(480, 640, SDL_WINDOW_SHOWN.rawValue, &window, &renderer) >= 0 else {
            fatalError("\(SDL_GetError())")
        }
        
        return (window: Window(pointer: window!), renderer: Renderer(pointer: renderer!))
    }
    
    private func handle(event: SDL_Event) {
    }
    
    private func update() {
    }
    
    private func render(_ renderer: Renderer, time: Double = 0) {
        renderer.drawColor = .random()
        renderer.clear()
        renderer.present()
    }
}

let app = App()
app.run()


