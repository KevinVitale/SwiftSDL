import Clibsdl2
import Foundation.NSThread

/**
 [Official Documentation](https://wiki.libsdl.org/CategoryVideo#Functions)
 */
class Window: WrappedPointer
{
    // MARK: - Destory
    override func destroy(pointer: OpaquePointer) {
        SDL_DestroyWindow(pointer)
    }
}

extension Window {
    struct Flags: OptionSet {
        var rawValue: SDL_WindowFlags.RawValue
        
        static let fullscreen           = Flags(rawValue: SDL_WINDOW_FULLSCREEN.rawValue)
        static let openGL               = Flags(rawValue: SDL_WINDOW_OPENGL.rawValue)
        static let shown                = Flags(rawValue: SDL_WINDOW_SHOWN.rawValue)
        static let hidden               = Flags(rawValue: SDL_WINDOW_HIDDEN.rawValue)
        static let borderless           = Flags(rawValue: SDL_WINDOW_BORDERLESS.rawValue)
        static let resizable            = Flags(rawValue: SDL_WINDOW_RESIZABLE.rawValue)
        static let minimized            = Flags(rawValue: SDL_WINDOW_MINIMIZED.rawValue)
        static let maximized            = Flags(rawValue: SDL_WINDOW_MAXIMIZED.rawValue)
        static let inputGrabbed         = Flags(rawValue: SDL_WINDOW_INPUT_GRABBED.rawValue)
        static let inputFocus           = Flags(rawValue: SDL_WINDOW_INPUT_FOCUS.rawValue)
        static let mouseFocus           = Flags(rawValue: SDL_WINDOW_MOUSE_FOCUS.rawValue)
        static let fullscreenDesktop    = Flags(rawValue: SDL_WINDOW_FULLSCREEN_DESKTOP.rawValue)
        static let foreign              = Flags(rawValue: SDL_WINDOW_FOREIGN.rawValue)
        static let allowHighDPI         = Flags(rawValue: SDL_WINDOW_ALLOW_HIGHDPI.rawValue)
        static let mouseCapture         = Flags(rawValue: SDL_WINDOW_MOUSE_CAPTURE.rawValue)
        static let alwaysOnTop          = Flags(rawValue: SDL_WINDOW_ALWAYS_ON_TOP.rawValue)
        static let skipTaskbar          = Flags(rawValue: SDL_WINDOW_SKIP_TASKBAR.rawValue)
        static let utility              = Flags(rawValue: SDL_WINDOW_UTILITY.rawValue)
        static let tooltop              = Flags(rawValue: SDL_WINDOW_TOOLTIP.rawValue)
        static let popUpMenu            = Flags(rawValue: SDL_WINDOW_POPUP_MENU.rawValue)
        static let vulkan               = Flags(rawValue: SDL_WINDOW_VULKAN.rawValue)
    }
}

// MARK: -
extension Window
{
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
    convenience init(title: String = "", x: Int32 = Int32(SDL_WINDOWPOS_UNDEFINED_MASK), y: Int32 = Int32(SDL_WINDOWPOS_UNDEFINED_MASK), width: Int32, height: Int32, flags: Flags...) throws {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        let title_ = title.cString(using: .utf8) ?? []
        guard let pointer = SDL_CreateWindow(title_, x, y, width, height, flags_) else {
            throw Error.error(Thread.callStackSymbols)
        }
        self.init(pointer: pointer)
    }
    
    /** TODO: Support `SDL_Error`, and `throw` instead. */
    convenience init(renderer: inout Renderer!, width: Int32, height: Int32, flags: Flags...) throws {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        var rendererPtr: OpaquePointer? = nil
        var windowPtr: OpaquePointer? = nil
        guard SDL_CreateWindowAndRenderer(width, height, flags_, &windowPtr, &rendererPtr) >= 0 else {
            throw Error.error(Thread.callStackSymbols)
        }
        
        renderer = Renderer(pointer: rendererPtr!)
        self.init(pointer: windowPtr!)
    }
}

// MARK: -
extension Window
{
    static func glWindow() throws -> Window {
        guard let pointer = SDL_GL_GetCurrentWindow() else {
            throw Error.error(Thread.callStackSymbols)
        }
        
        return .init(pointer: pointer)
    }
    
    func glSwap() {
        SDL_GL_SwapWindow(pointer)
    }
    
    var glContext: SDL_GLContext! {
        get { return SDL_GL_GetCurrentContext() }
        set { SDL_GL_MakeCurrent(pointer, newValue) }
    }
}

// MARK: -
extension Window
{
    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func has(flags: SDL_WindowFlags...) -> Bool {
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (SDL_GetWindowFlags(pointer) & mask) != 0
    }
}

// MARK: -
extension Window
{
    /*
    var gamma: Float {
        get { return SDL_GetWindowBrightness(pointer) }
        set { SDL_SetWindowBrightness(pointer, newValue) }
    }
     */
    
    /// Get the window's display mode.
    var displayMode: SDL_DisplayMode {
        var displayMode = SDL_DisplayMode()
        SDL_GetWindowDisplayMode(pointer, &displayMode)
        return displayMode
    }
    
    /*
    var grabbed: Bool {
        get { return SDL_GetWindowGrab(pointer).boolValue }
        set { SDL_SetWindowGrab(pointer, .init(booleanLiteral: newValue))}
    }
     */

    /// Get the numeric ID of a window, for logging purposes.
    var id: UInt32 {
        return SDL_GetWindowID(pointer)
    }
    
    //
    var position: (x: Int32, y: Int32) {
        get {
            var x: Int32 = 0, y: Int32 = 0
            SDL_GetWindowPosition(pointer, &x, &y)
            return (x, y)
        }
        set {
           SDL_SetWindowPosition(pointer, newValue.x, newValue.y)
        }
    }

    /**
     Set the user-resizable state of a window.
     
     This will add or remove the window's `SDL_WINDOW_RESIZABLE` flag and
     allow/disallow user resizing of the window. This is a no-op if the window's
     resizable state already matches the requested state.
     
     - note: You can't change the resizable state of a fullscreen window.
     */
    var resizable: Bool {
        get { return has(flags: SDL_WINDOW_RESIZABLE) }
        set {
            SDL_SetWindowResizable(pointer, newValue.toSDL)
            
        }
    }
    
    //
    var size: (width: Int32, height: Int32) {
        get {
            var w: Int32 = 0, h: Int32 = 0
            SDL_GetWindowSize(pointer, &w, &h)
            return (width: w, height: h)
        }
        set {
            SDL_SetWindowSize(pointer, newValue.width, newValue.height)
        }
    }
    
    var title: String {
        get {
            return String(cString: SDL_GetWindowTitle(pointer)!)
        }
        set {
            newValue.withCString { bytes in
                SDL_SetWindowTitle(pointer, bytes)
            }
        }
    }
    
    /**
     Get the SDL surface associated with the window.
     
     A new surface will be created with the optimal format for the window, if
     necessary. This surface will be freed when the window is destroyed.
     
     - note: You may not combine this with 3D or the rendering API on this window.
     */
    var surface: UnsafeMutablePointer<SDL_Surface>! {
        return SDL_GetWindowSurface(pointer)
    }
}

// MARK: -
extension Window
{
    /*
    static func grabbed() -> Window? {
        guard let pointer = SDL_GetGrabbedWindow() else {
            return nil
        }
        
        return .init(pointer: pointer)
    }
     */
}


