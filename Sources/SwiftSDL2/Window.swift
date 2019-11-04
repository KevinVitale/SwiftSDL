import Foundation
import CSDL2

public extension UInt32 {
    static func windowFlags(_ flags: Window.Flag...) -> UInt32 {
        flags.reduce(0) { $0 | $1.rawValue }
    }
}

public class Window: SDLPointer<Window>, SDLType {
    public struct Flag: OptionSet {
        public init(rawValue: SDL_WindowFlags.RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_WindowFlags.RawValue
        
        public static let fullscreen           = Flag(rawValue: SDL_WINDOW_FULLSCREEN.rawValue)
        public static let openGL               = Flag(rawValue: SDL_WINDOW_OPENGL.rawValue)
        public static let shown                = Flag(rawValue: SDL_WINDOW_SHOWN.rawValue)
        public static let hidden               = Flag(rawValue: SDL_WINDOW_HIDDEN.rawValue)
        public static let borderless           = Flag(rawValue: SDL_WINDOW_BORDERLESS.rawValue)
        public static let resizable            = Flag(rawValue: SDL_WINDOW_RESIZABLE.rawValue)
        public static let minimized            = Flag(rawValue: SDL_WINDOW_MINIMIZED.rawValue)
        public static let maximized            = Flag(rawValue: SDL_WINDOW_MAXIMIZED.rawValue)
        public static let inputGrabbed         = Flag(rawValue: SDL_WINDOW_INPUT_GRABBED.rawValue)
        public static let inputFocus           = Flag(rawValue: SDL_WINDOW_INPUT_FOCUS.rawValue)
        public static let mouseFocus           = Flag(rawValue: SDL_WINDOW_MOUSE_FOCUS.rawValue)
        public static let fullscreenDesktop    = Flag(rawValue: SDL_WINDOW_FULLSCREEN_DESKTOP.rawValue)
        public static let foreign              = Flag(rawValue: SDL_WINDOW_FOREIGN.rawValue)
        public static let allowHighDPI         = Flag(rawValue: SDL_WINDOW_ALLOW_HIGHDPI.rawValue)
        public static let mouseCapture         = Flag(rawValue: SDL_WINDOW_MOUSE_CAPTURE.rawValue)
        public static let alwaysOnTop          = Flag(rawValue: SDL_WINDOW_ALWAYS_ON_TOP.rawValue)
        public static let skipTaskbar          = Flag(rawValue: SDL_WINDOW_SKIP_TASKBAR.rawValue)
        public static let utility              = Flag(rawValue: SDL_WINDOW_UTILITY.rawValue)
        public static let tooltop              = Flag(rawValue: SDL_WINDOW_TOOLTIP.rawValue)
        public static let popUpMenu            = Flag(rawValue: SDL_WINDOW_POPUP_MENU.rawValue)
        public static let vulkan               = Flag(rawValue: SDL_WINDOW_VULKAN.rawValue)
    }
    
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyWindow(pointer)
    }
    
    public convenience init(title: String = "", xPos x: Int32 = Int32(SDL_WINDOWPOS_CENTERED_MASK), yPos y: Int32 = Int32(SDL_WINDOWPOS_CENTERED_MASK), width w: Int32, height h: Int32, flags: Flag...) throws {
        let f = flags.reduce(0) { $0 | $1.rawValue }
        guard let pointer = title.withCString({ SDL_CreateWindow($0, x, y, w, h, f) }) else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        self.init(pointer: pointer)
    }
    
    public convenience init(title: String = "", renderer: inout Renderer!, width w: Int32, height h: Int32, flags: Flag...) throws {
        var windowPtr: OpaquePointer! = nil
        var renderPtr: OpaquePointer! = nil
        let f = flags.reduce(0) { $0 | $1.rawValue }
        guard SDL_CreateWindowAndRenderer(w, h, f, &windowPtr, &renderPtr) == 0 else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        renderer = Renderer(pointer: renderPtr)
        self.init(pointer: windowPtr)
    }
}
