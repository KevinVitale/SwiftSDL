import Foundation
import CSDL2

public typealias Window = SDLPointer<SDLWindow>

public extension UInt32 {
    static func windowFlags(_ flags: Window.WindowFlag...) -> UInt32 {
        flags.reduce(0) { $0 | $1.rawValue }
    }
}

public struct SDLWindow: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyWindow(pointer)
    }
}

public extension SDLPointer where T == SDLWindow {
    struct WindowFlag: OptionSet {
        public init(rawValue: SDL_WindowFlags.RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_WindowFlags.RawValue
        
        public static let fullscreen           = WindowFlag(rawValue: SDL_WINDOW_FULLSCREEN.rawValue)
        public static let openGL               = WindowFlag(rawValue: SDL_WINDOW_OPENGL.rawValue)
        public static let shown                = WindowFlag(rawValue: SDL_WINDOW_SHOWN.rawValue)
        public static let hidden               = WindowFlag(rawValue: SDL_WINDOW_HIDDEN.rawValue)
        public static let borderless           = WindowFlag(rawValue: SDL_WINDOW_BORDERLESS.rawValue)
        public static let resizable            = WindowFlag(rawValue: SDL_WINDOW_RESIZABLE.rawValue)
        public static let minimized            = WindowFlag(rawValue: SDL_WINDOW_MINIMIZED.rawValue)
        public static let maximized            = WindowFlag(rawValue: SDL_WINDOW_MAXIMIZED.rawValue)
        public static let inputGrabbed         = WindowFlag(rawValue: SDL_WINDOW_INPUT_GRABBED.rawValue)
        public static let inputFocus           = WindowFlag(rawValue: SDL_WINDOW_INPUT_FOCUS.rawValue)
        public static let mouseFocus           = WindowFlag(rawValue: SDL_WINDOW_MOUSE_FOCUS.rawValue)
        public static let fullscreenDesktop    = WindowFlag(rawValue: SDL_WINDOW_FULLSCREEN_DESKTOP.rawValue)
        public static let foreign              = WindowFlag(rawValue: SDL_WINDOW_FOREIGN.rawValue)
        public static let allowHighDPI         = WindowFlag(rawValue: SDL_WINDOW_ALLOW_HIGHDPI.rawValue)
        public static let mouseCapture         = WindowFlag(rawValue: SDL_WINDOW_MOUSE_CAPTURE.rawValue)
        public static let alwaysOnTop          = WindowFlag(rawValue: SDL_WINDOW_ALWAYS_ON_TOP.rawValue)
        public static let skipTaskbar          = WindowFlag(rawValue: SDL_WINDOW_SKIP_TASKBAR.rawValue)
        public static let utility              = WindowFlag(rawValue: SDL_WINDOW_UTILITY.rawValue)
        public static let tooltop              = WindowFlag(rawValue: SDL_WINDOW_TOOLTIP.rawValue)
        public static let popUpMenu            = WindowFlag(rawValue: SDL_WINDOW_POPUP_MENU.rawValue)
        public static let vulkan               = WindowFlag(rawValue: SDL_WINDOW_VULKAN.rawValue)
    }
    
    convenience init(title: String = "", xPos x: Int32 = Int32(SDL_WINDOWPOS_CENTERED_MASK), yPos y: Int32 = Int32(SDL_WINDOWPOS_CENTERED_MASK), width w: Int32, height h: Int32, flags: WindowFlag...) throws {
        let f = flags.reduce(0) { $0 | $1.rawValue }
        guard let pointer = title.withCString({ SDL_CreateWindow($0, x, y, w, h, f) }) else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        self.init(pointer: pointer)
    }
    
    convenience init(title: String = "", renderer: inout Renderer, width w: Int32, height h: Int32, flags: WindowFlag...) throws {
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
