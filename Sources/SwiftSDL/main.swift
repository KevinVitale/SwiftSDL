import Clibsdl2

@discardableResult
func Initialize(flags: UInt32...) -> Int32 {
    return SDL_Init(flags.reduce(0) { $0 | $1 })
}

class App {
    func run() {
        defer { SDL_Quit() }

        var renderer: Renderer! = nil
        let window = Window(renderer: &renderer, width: 480, height: 640)!
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

Initialize(flags: SDL_INIT_VIDEO, SDL_INIT_TIMER)

let app = App()
app.run()


