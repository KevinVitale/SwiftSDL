import Foundation
import CSDL2

extension SDL.Engine {
    public struct Display: Identifiable {
        public let id: Int32
        
        public var name: String {
            SDL_GetDisplayName(id).map(String.init) ?? "Video Display #\(id)"
        }
        
        public func modes() -> [SDL_DisplayMode] {
            let numberOfModes = SDL_GetNumDisplayModes(self.id)
            var  displayModes = [SDL_DisplayMode]()
            var   displayMode = SDL_DisplayMode()
            
            for mode in 0..<numberOfModes {
                SDL_GetDisplayMode(self.id, mode, &displayMode)
                displayModes.append(displayMode)
            }
            
            return displayModes
        }
    }
    
    public var videoDisplays: [Display] {
        (0..<SDL_GetNumVideoDisplays()).map(Display.init(id:))
    }
}
