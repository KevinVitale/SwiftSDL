import Foundation

public extension SDL {
    @available(OSX 10.12, *) 
    static func Run(onRunLoop runLoop: RunLoop = .main, _ closure: (_: Engine) throws -> ()) rethrows -> Never {
        let engine = Engine()
        try closure(engine)
        
        // Add the game loop (on a timer) --------------------------------------
        var previousDate: TimeInterval = .infinity
        let timer = Timer(timeInterval: 1/60, repeats: true) { timer in
            guard engine.isRunning else {
                timer.invalidate()
                return
            }
            
            let currentDate = timer.fireDate.timeIntervalSince1970
            
            if previousDate.isInfinite {
                previousDate = currentDate
            }

            engine.handleInput()
            engine.update(currentDate - previousDate)
            engine.render()
            
            previousDate = currentDate
        }
        runLoop.add(timer, forMode: .default)
        
        // Run until 'engine' is shutdown --------------------------------------
        while engine.isRunning && runLoop.run(mode: .default, before: .distantFuture) {
            /* no-op */
        }

        // Quit all subsystems & exit application ------------------------------
        engine.quit(EXIT_SUCCESS)
    }
}
