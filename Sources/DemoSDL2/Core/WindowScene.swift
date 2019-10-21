import Foundation
import CSDL2
import SwiftSDL2

class WindowScene: Node, Identifiable {
    required init(window: Window, renderer: Renderer?) {
        self.window   = window
        self.renderer = renderer
    }
    
    convenience init(window windowInfo: (title: String, width: Int32, height: Int32), backgroundColor: SDL_Color = SDL_Color(r: 255, g: 255, b: 255, a: 255), windowFlags: Window.WindowFlag = [], renderFlags: Renderer.RenderFlag = []) throws {
        var window: Window!
        var renderer: Renderer!
        
        switch renderFlags.isEmpty {
        case true:
            window = try Window(title: windowInfo.title, renderer: &renderer, width: windowInfo.width, height: windowInfo.height, flags: windowFlags)
        case false:
            window = try Window(title: windowInfo.title, width: windowInfo.width, height: windowInfo.height, flags: windowFlags)
            renderer = window
                .pass(to: SDL_CreateRenderer, -1, .renderFlags(renderFlags))
                .map(Renderer.init)
        }

        self.init(window: window, renderer: renderer)
        self.backgroundColor = backgroundColor
    }
    
    private(set) var lastUpdateInterval: TimeInterval = .zero {
        didSet {
            if self.enableUpdateIntervalLogging {
                print(lastUpdateInterval)
            }
        }
    }

    private var actions: [Action] = []
    private var trackUpdateIntervalAction: Action? {
        willSet {
            actions.removeAll {
                guard let action = self.trackUpdateIntervalAction else {
                    return false
                }
                return $0 == action
            }
        }
        didSet {
            if let trackUpdateIntervalAction = self.trackUpdateIntervalAction {
                self.actions.append(trackUpdateIntervalAction)
            }
        }
    }

    let window: Window
    let renderer: Renderer?
    
    var backgroundColor: SDL_Color = SDL_Color()
    var enableUpdateIntervalLogging: Bool = false

    static func == (lhs: WindowScene, rhs: WindowScene) -> Bool {
        lhs.window == rhs.window
    }
    
    func hash(into hasher: inout Hasher) {
        self.window.hash(into: &hasher)
    }
    
    func draw(atTime timeInterval: TimeInterval) {
        self.renderer?.result(of: SDL_SetRenderDrawColor, backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
        self.renderer?.result(of: SDL_RenderClear)
        
        self.draw(children: self.children)
        
        self.renderer?.pass(to: SDL_RenderPresent)
    }

    private func draw<N: Node>(children: [N]) {
        children.forEach { node in
            if let node = node as? Drawable {
                node.draw(renderer: renderer)
            }
            self.draw(children: node.children)
        }
    }
    
    func update(atTime timeInterval: TimeInterval) {
        self.actions.forEach {
            $0.update(atTime: timeInterval)
        }
    }
    
    func attach(actions: Action...) {
        self.actions += actions
    }
    
    func handleInput(from event: SDL_Event) {
    }
    
    @available(OSX 10.12, *)
    func willPresent(to game: Game) throws {
        self.trackUpdateIntervalAction = Action(repeats: true) {
            self.lastUpdateInterval = $0
        }
    }
    
    @available(OSX 10.12, *)
    func didPresent(to game: Game) throws {
    }
}
