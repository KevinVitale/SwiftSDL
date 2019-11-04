import Foundation
import CSDL2
import SwiftSDL2

class WindowScene: Node, Identifiable {
    required init(window: Window, renderer: Renderer?) {
        self.window   = window
        self.renderer = renderer
    }
    
    convenience init(window windowInfo: (title: String, width: Int32, height: Int32), backgroundColor: SDL_Color = SDL_Color(r: 255, g: 255, b: 255, a: 255), windowFlags: Window.Flag = [], renderFlags: Renderer.RenderFlag = []) throws {
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
    
    let window: Window
    let renderer: Renderer?
    
    var backgroundColor: SDL_Color = SDL_Color()

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
        self.update(nodes: self.children, atTime: timeInterval)
        self.actions.forEach {
            $0.update(atTime: timeInterval)
        }
    }
    
    private func update<N: Node>(nodes: [N], atTime timeInterval: TimeInterval) {
        nodes.forEach { node in
            node.actions.forEach {
                $0.update(atTime: timeInterval)
            }
            self.update(nodes: node.children, atTime: timeInterval)
        }
    }

    func handleInput(from event: SDL_Event) {
    }
    
    @available(OSX 10.12, *)
    func willPresent(to game: Game) throws {
    }
    
    @available(OSX 10.12, *)
    func didPresent(to game: Game) throws {
    }
}
