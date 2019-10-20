import Foundation
import CSDL2
import SwiftSDL2

struct Display: Identifiable {
    var id: Int32
    func modes() -> [SDL_DisplayMode] {
        (0..<SDL_GetNumDisplayModes(self.id)).map { mode -> SDL_DisplayMode in
            var displayMode = SDL_DisplayMode()
            SDL_GetDisplayMode(self.id, mode, &displayMode)
            return displayMode
        }
    }
    
    static let allDisplays = (0..<SDL_GetNumVideoDisplays()).map(Display.init)
}

