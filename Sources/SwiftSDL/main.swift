import Clibsdl2
import Dispatch



class App {
    func run() {
        var (window, renderer) = initialize();
        defer { cleanup(window: window, renderer: renderer) }
        
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
            render(&renderer)
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
    
    private func render(_ renderer: inout Renderer, time: Double = 0) {
        renderer.drawColor = .random()
        renderer.clear()
        renderer.present()
    }
    
    private func cleanup(window: Window, renderer: Renderer) {
        SDL_DestroyRenderer(renderer.pointer)
        SDL_DestroyWindow(window.pointer)
        SDL_Quit()
    }
}

let app = App()
app.run()


