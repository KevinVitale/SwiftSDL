import Foundation
import CSDL2
import SwiftSDL2

@available(OSX 10.12, *)
class Game {
    init(loopFrequency frequency: TimeInterval) {
        self.updateLoop = UpdateLoop(frequency: frequency)
    }
    
    private var scene: WindowScene?
    private var updateLoop: UpdateLoop

    final func initialize() throws {
        try SDL.Init(subSystems: .everything)
        SDL.Hint.set("1", for: .renderBatching)
    }
    
    final func shutdown() -> Never {
        SDL.Quit(subSystems: .everything)
        exit(EXIT_SUCCESS)
    }
    
    final func start(onRunLoop runLoop: RunLoop = .current) -> Never {
        updateLoop.run(update)
        
        while updateLoop.isValid && runLoop.run(mode: .default, before: .distantFuture) {
            /* no-op */
        }
        
        self.shutdown()
    }
    
    final func stop() {
        self.updateLoop.terminate()
    }
    
    private func readInput() -> SDL_Event {
        var event = SDL_Event()
        while(SDL_PollEvent(&event) != 0) {
            if event.type == SDL_QUIT.rawValue {
                self.stop()
            }
        }
        return event
    }
    
    private func update(atTime timeInterval: TimeInterval) {
        self.scene?.handleInput(from: readInput())
        self.scene?.update(atTime: timeInterval)
        self.scene?.draw(atTime: timeInterval)
    }
    
    func present(scene: WindowScene) throws {
        try scene.willPresent(to: self)
        self.scene = scene
        try scene.didPresent(to: self)
    }
}

