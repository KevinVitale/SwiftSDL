import Foundation
import CSDL2

extension SDL.Engine {
    public struct Display: Identifiable {
        public let id: Int32
        
        public var name: String {
            SDL_GetDisplayName(id).map(String.init) ?? "Video Display #\(id)"
        }
        
        private var displayDPI: (Float, Float, Float) {
            var ddpi: Float = 0, hdpi: Float = 0, vdpi: Float = 0
            SDL_GetDisplayDPI(id, &ddpi, &hdpi, &vdpi)
            return (ddpi, hdpi, vdpi)
        }
        
        public var ddpi: Float { displayDPI.0 }
        public var hdpi: Float { displayDPI.1 }
        public var vdpi: Float { displayDPI.2 }
        
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
