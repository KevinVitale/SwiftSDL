import Foundation

public extension SDL {
    static func Run(onRunLoop runLoop: RunLoop = .main, _ closure: (_: Engine) throws -> ()) rethrows -> Never {
        let engine = Engine()
        try closure(engine)
        
        // Add the game loop (on a timer) --------------------------------------
        if #available(OSX 10.12, *) {
            let timer = Timer(timeInterval: 1/60, repeats: true) { timer in
                guard engine.isRunning else {
                    timer.invalidate()
                    return
                }
                
                engine.handleInput()
                engine.update(timer.fireDate.timeIntervalSince1970)
                engine.render()
            }
            runLoop.add(timer, forMode: .default)
        } else {
            engine.stop()
        }

        // Run until 'engine' is shutdown --------------------------------------
        while engine.isRunning && runLoop.run(mode: .default, before: .distantFuture) {
            /* no-op */
        }

        // Quit all subsystems & exit application ------------------------------
        engine.quit(EXIT_SUCCESS)
    }
}
