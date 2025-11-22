public protocol Window: SDL_ObjectProtocol, SDL_PropertyTypeValue where Pointer == OpaquePointer { }

extension SDL_Object<OpaquePointer>: Window {
  public convenience init(with properties: [SDL_WindowProperty]) throws(SDL_Error) {
    try self.init(with: try SDL_PropertiesID(properties: properties))
  }
  
  public convenience init(with properties: SDL_PropertiesID) throws(SDL_Error) {
    guard let windowPtr = __SDL_CreateWindowWithProperties(properties.id) else {
      throw .error
    }
    self.init(windowPtr, destroy: SDL_DestroyWindow)
  }
}

extension Window {
  // public var id: Result<UInt32, SDL_Error> { self.resultOf(SDL_GetWindowID) }
  // public var title: Result<String, SDL_Error> { self .resultOf(SDL_GetWindowTitle).map(String.init(cString:)) }
}

extension Window {
  public var surface: Result<any Surface, SDL_Error> {
    self
      .resultOf(SDL_GetWindowSurface)
      .map({ SDL_Object($0, tag: "(unowned) window surface") })
  }
  
  public var renderer: Result<any Renderer, SDL_Error> {
    self
      .resultOf(SDL_GetRenderer)
      .map({ SDL_Object($0, tag: "(unowned) window renderer") })
  }
}

extension Window {
  public func `is`(_ flag: SDL_WindowFlags) -> Bool { flags & flag.rawValue != 0 }
  public func isNot(_ flag: SDL_WindowFlags) -> Bool { !`is`(flag) }
  var flags: UInt64 { try! self(SDL_GetWindowFlags) }
}

/// Required because `libsdl` wraps all these values with a `SDL_UINT64_C` C-macro
public enum SDL_WindowFlags: UInt64 {
  /** window is in fullscreen mode */
  case fullscreen           = 0x0000000000000001
  
  /** window usable with OpenGL context */
  case opengl               = 0x0000000000000002
  
  /** window is occluded */
  case occluded             = 0x0000000000000004
  
  /** window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; SDL_ShowWindow() is required for it to become visible */
  case hidden               = 0x0000000000000008
  
  /** no window decoration */
  case borderless           = 0x0000000000000010
  
  /** window can be resized */
  case resizable            = 0x0000000000000020
  
  /** window is minimized */
  case minimized            = 0x0000000000000040
  
  /** window is maximized */
  case maximized            = 0x0000000000000080
  
  /** window has grabbed mouse input */
  case mouse_grabbed        = 0x0000000000000100
  
  /** window has input focus */
  case input_focus          = 0x0000000000000200
  
  /** window has mouse focus */
  case mouse_focus          = 0x0000000000000400
  
  /** window not created by SDL */
  case external             = 0x0000000000000800
  
  /** window is modal */
  case modal                = 0x0000000000001000
  
  /** window uses high pixel density back buffer if possible */
  case high_pixel_density   = 0x0000000000002000
  
  /** window has mouse captured (unrelated to MOUSE_GRABBED) */
  case mouse_capture        = 0x0000000000004000
  
  /** window has relative mode enabled */
  case mouse_relative_mode  = 0x0000000000008000
  
  /** window should always be above others */
  case always_on_top        = 0x0000000000010000
  
  /** window should be treated as a utility window, not showing in the task bar and window list */
  case utility              = 0x0000000000020000
  
  /** window should be treated as a tooltip and does not get mouse or keyboard focus, requires a parent window */
  case tooltip              = 0x0000000000040000
  
  /** window should be treated as a popup menu, requires a parent window */
  case popup_menu           = 0x0000000000080000
  
  /** window has grabbed keyboard input */
  case keyboard_grabbed     = 0x0000000000100000
  
  /** window usable for Vulkan surface */
  case vulkan               = 0x0000000010000000
  
  /** window usable for Metal view */
  case metal                = 0x0000000020000000
  
  /** window with transparent buffer */
  case transparent          = 0x0000000040000000
  
  /** window should not be focusable */
  case not_focusable        = 0x0000000080000000
}

extension Sint64 {
  public static let windowCenter = Self(SDL_WINDOWPOS_CENTERED_MASK)
}

extension Int32 {
  public static let windowCenter = Self(SDL_WINDOWPOS_CENTERED_MASK)
}

extension Point<Int32> {
  public static let windowCenter = Point<Int32>(x: .windowCenter, y: .windowCenter)
}

extension SDL_Point {
  public static let windowCenter = Self(x: .windowCenter, y: .windowCenter)
}

extension SDL_PropertiesID {
  public convenience init(id: ID? = nil, properties: SDL_WindowProperty...) throws(SDL_Error) {
    try self.init(id: id, properties: properties)
    
  }
  public convenience init(id: ID? = nil, properties: [SDL_WindowProperty]) throws(SDL_Error) {
    try self.init(id: id,  properties: properties.map { ($0.property, $0.wrappedValue) })
  }
}

@propertyWrapper
public enum SDL_WindowProperty {
  case alwaysOnTop(Bool)
  case borderless(Bool)
  case constrainPopup(Bool)
  case focusable(Bool)
  case externalGraphicsContext(Bool)
  case flags(Sint64)
  case fullscreen(Bool)
  case height(Sint64)
  case hidden(Bool)
  case hdpi(Bool)
  case maximized(Bool)
  case menu(Bool)
  case metal(Bool)
  case minimized(Bool)
  case modal(Bool)
  case grabbed(Bool)
  case openGL(Bool)
  case parent(UnsafeMutableRawPointer!)
  case resizable(Bool)
  case windowTitle(String)
  case transparent(Bool)
  case tooltip(Bool)
  case utility(Bool)
  case vulkan(Bool)
  case width(Sint64)
  case positionX(Sint64)
  case positionY(Sint64)
  case cocoaWindow(UnsafeMutableRawPointer!)
  case cocoaView(UnsafeMutableRawPointer!)
  case waylandSurfaceRoleCustom(Bool)
  case waylandCreateEGLWindow(Bool)
  case waylandWLSurface(UnsafeMutableRawPointer!)
  case win32WindowHandle(UnsafeMutableRawPointer!)
  case wind32PixelFormat(UnsafeMutableRawPointer!)
  case x11Window(UnsafeMutableRawPointer!)
  
  public var property: String {
    switch self {
      case .alwaysOnTop: return SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN
      case .borderless: return SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN
      case .constrainPopup: return SDL_PROP_WINDOW_CREATE_CONSTRAIN_POPUP_BOOLEAN
      case .focusable: return SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN
      case .externalGraphicsContext: return SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN
      case .flags: return SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER
      case .fullscreen: return SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN
      case .height: return SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER
      case .hidden: return SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN
      case .hdpi: return SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN
      case .maximized: return SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN
      case .menu: return SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN
      case .metal: return SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN
      case .minimized: return SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN
      case .modal: return SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN
      case .grabbed: return SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN
      case .openGL: return SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN
      case .parent: return SDL_PROP_WINDOW_CREATE_PARENT_POINTER
      case .resizable: return SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN
      case .windowTitle: return SDL_PROP_WINDOW_CREATE_TITLE_STRING
      case .transparent: return SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN
      case .tooltip: return SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN
      case .utility: return SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN
      case .vulkan: return SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN
      case .width: return SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER
      case .positionX: return SDL_PROP_WINDOW_CREATE_X_NUMBER
      case .positionY: return SDL_PROP_WINDOW_CREATE_Y_NUMBER
      case .cocoaWindow: return SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER
      case .cocoaView: return SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER
      case .waylandSurfaceRoleCustom: return SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN
      case .waylandCreateEGLWindow: return SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN
      case .waylandWLSurface: return SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER
      case .win32WindowHandle: return SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER
      case .wind32PixelFormat: return SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER
      case .x11Window: return SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER
    }
  }
  
  public var wrappedValue: (any SDL_PropertyTypeValue) {
    switch self {
      case .alwaysOnTop(let value): return value
      case .borderless(let value): return value
      case .constrainPopup(let value): return value
      case .focusable(let value): return value
      case .externalGraphicsContext(let value): return value
      case .flags(let value): return value
      case .fullscreen(let value): return value
      case .height(let value): return value
      case .hidden(let value): return value
      case .hdpi(let value): return value
      case .maximized(let value): return value
      case .menu(let value): return value
      case .metal(let value): return value
      case .minimized(let value): return value
      case .modal(let value): return value
      case .grabbed(let value): return value
      case .openGL(let value): return value
      case .parent(let value): return value
      case .resizable(let value): return value
      case .windowTitle(let value): return value
      case .transparent(let value): return value
      case .tooltip(let value): return value
      case .utility(let value): return value
      case .vulkan(let value): return value
      case .width(let value): return value
      case .positionX(let value): return value
      case .positionY(let value): return value
      case .cocoaWindow(let value): return value
      case .cocoaView(let value): return value
      case .waylandSurfaceRoleCustom(let value): return value
      case .waylandCreateEGLWindow(let value): return value
      case .waylandWLSurface(let value): return value
      case .win32WindowHandle(let value): return value
      case .wind32PixelFormat(let value): return value
      case .x11Window(let value): return value
    }
  }
}
