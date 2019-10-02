import Foundation
import CSDL2

public struct SDLWindow: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyWindow(pointer)
    }
}

public extension SDL { typealias Window = SDLPointer<SDLWindow> }

public extension SDLPointer where T == SDLWindow {
    typealias DisplayMode = SDL_DisplayMode
    typealias GLContext   = SDL_GLContext

    struct WindowFlags: OptionSet {
        public init(rawValue: SDL_WindowFlags.RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_WindowFlags.RawValue
        
        public static let fullscreen           = WindowFlags(rawValue: SDL_WINDOW_FULLSCREEN.rawValue)
        public static let openGL               = WindowFlags(rawValue: SDL_WINDOW_OPENGL.rawValue)
        public static let shown                = WindowFlags(rawValue: SDL_WINDOW_SHOWN.rawValue)
        public static let hidden               = WindowFlags(rawValue: SDL_WINDOW_HIDDEN.rawValue)
        public static let borderless           = WindowFlags(rawValue: SDL_WINDOW_BORDERLESS.rawValue)
        public static let resizable            = WindowFlags(rawValue: SDL_WINDOW_RESIZABLE.rawValue)
        public static let minimized            = WindowFlags(rawValue: SDL_WINDOW_MINIMIZED.rawValue)
        public static let maximized            = WindowFlags(rawValue: SDL_WINDOW_MAXIMIZED.rawValue)
        public static let inputGrabbed         = WindowFlags(rawValue: SDL_WINDOW_INPUT_GRABBED.rawValue)
        public static let inputFocus           = WindowFlags(rawValue: SDL_WINDOW_INPUT_FOCUS.rawValue)
        public static let mouseFocus           = WindowFlags(rawValue: SDL_WINDOW_MOUSE_FOCUS.rawValue)
        public static let fullscreenDesktop    = WindowFlags(rawValue: SDL_WINDOW_FULLSCREEN_DESKTOP.rawValue)
        public static let foreign              = WindowFlags(rawValue: SDL_WINDOW_FOREIGN.rawValue)
        public static let allowHighDPI         = WindowFlags(rawValue: SDL_WINDOW_ALLOW_HIGHDPI.rawValue)
        public static let mouseCapture         = WindowFlags(rawValue: SDL_WINDOW_MOUSE_CAPTURE.rawValue)
        public static let alwaysOnTop          = WindowFlags(rawValue: SDL_WINDOW_ALWAYS_ON_TOP.rawValue)
        public static let skipTaskbar          = WindowFlags(rawValue: SDL_WINDOW_SKIP_TASKBAR.rawValue)
        public static let utility              = WindowFlags(rawValue: SDL_WINDOW_UTILITY.rawValue)
        public static let tooltop              = WindowFlags(rawValue: SDL_WINDOW_TOOLTIP.rawValue)
        public static let popUpMenu            = WindowFlags(rawValue: SDL_WINDOW_POPUP_MENU.rawValue)
        public static let vulkan               = WindowFlags(rawValue: SDL_WINDOW_VULKAN.rawValue)
    }
    
    // MARK: - Create
    /**
     Create a new `Window`.
     
     - parameter title: The title.
     - parameter x: The `x` position, in screen space.
     - parameter y: The `y` position, in screen space.
     - parameter width: The horizontal size.
     - parameter height: The vertical size.
     - parameter flags: Additional properties used when creating the window. See: `SDL_WindowFlags`.
     
     - returns: A new `Window`, or `nil`, if creating the window fails.
     */
    convenience init(title: String = "", x: Int32 = Int32(SDL_WINDOWPOS_UNDEFINED_MASK), y: Int32 = Int32(SDL_WINDOWPOS_UNDEFINED_MASK), width: Int32, height: Int32, flags: WindowFlags...) throws {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        let title_ = title.cString(using: .utf8) ?? []
        
        guard let pointer = SDL_CreateWindow(title_, x, y, width, height, flags_) else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        self.init(pointer: pointer)
    }
    
    convenience init(renderer: inout SDL.Renderer!, width: Int32, height: Int32, flags: WindowFlags...) throws {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        var rendererPtr: OpaquePointer? = nil
        var windowPtr: OpaquePointer? = nil
        
        guard SDL_CreateWindowAndRenderer(width, height, flags_, &windowPtr, &rendererPtr) >= 0 else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        
        renderer = SDL.Renderer(pointer: rendererPtr!)
        self.init(pointer: windowPtr!)
    }
    
    static func glWindow() throws -> SDL.Window {
        guard let pointer = SDL_GL_GetCurrentWindow() else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        
        return SDL.Window(pointer: pointer)
    }
    
    func glSwap() {
        SDL_GL_SwapWindow(_pointer)
    }
    
    var glContext: SDL_GLContext! {
        get { return SDL_GL_GetCurrentContext() }
        set { SDL_GL_MakeCurrent(_pointer, newValue) }
    }
    
    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func has(flags: WindowFlags...) -> Bool {
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (SDL_GetWindowFlags(_pointer) & mask) != 0
    }
    
    /// Get the window's display mode.
    var displayMode: DisplayMode {
        var displayMode = DisplayMode()
        SDL_GetWindowDisplayMode(_pointer, &displayMode)
        return displayMode
    }
    
    var surface: Result<Surface, Error> {
        return Surface.surface(forWindow: self)
    }

    var title: String {
        get {
            guard let cString = SDL_GetWindowTitle(_pointer) else {
                return ""
            }
            return String(cString: cString)
        }
        set {
            newValue.withCString {
                SDL_SetWindowTitle(_pointer, $0)
            }
        }
    }
}
