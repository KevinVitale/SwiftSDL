public enum WindowProperty {
  case alwaysOnTop(Bool)
  case borderless(Bool)
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
  
  var value: (__SDL_WindowCreateFlags, (any PropertyValue)) {
    switch self {
      case .alwaysOnTop(let value): return (.alwaysOnTop, value)
      case .borderless(let value): return (.borderless, value)
      case .focusable(let value): return (.focusable, value)
      case .externalGraphicsContext(let value): return (.externalGraphicsContext, value)
      case .flags(let value): return (.flags, value)
      case .fullscreen(let value): return (.focusable, value)
      case .height(let value): return (.height, value)
      case .hidden(let value): return (.hidden, value)
      case .hdpi(let value): return (.hdpi, value)
      case .maximized(let value): return (.maximized, value)
      case .menu(let value): return (.menu, value)
      case .metal(let value): return (.metal, value)
      case .minimized(let value): return (.minimized, value)
      case .modal(let value): return (.modal, value)
      case .grabbed(let value): return (.grabbed, value)
      case .openGL(let value): return (.openGL, value)
      case .parent(let value): return (.parent, value)
      case .resizable(let value): return (.resizable, value)
      case .windowTitle(let value): return (.windowTitle, value)
      case .transparent(let value): return (.transparent, value)
      case .tooltip(let value): return (.tooltip, value)
      case .utility(let value): return (.utility, value)
      case .vulkan(let value): return (.vulkan, value)
      case .width(let value): return (.width, value)
      case .positionX(let value): return (.positionX, value)
      case .positionY(let value): return (.positionY, value)
      case .cocoaWindow(let value): return (.cocoaWindow, value)
      case .cocoaView(let value): return (.cocoaView, value)
      case .waylandSurfaceRoleCustom(let value): return (.waylandSurfaceRoleCustom, value)
      case .waylandCreateEGLWindow(let value): return (.waylandCreateEGLWindow, value)
      case .waylandWLSurface(let value): return (.waylandWLSurface, value)
      case .win32WindowHandle(let value): return (.win32WindowHandle, value)
      case .wind32PixelFormat(let value): return (.wind32PixelFormat, value)
      case .x11Window(let value): return (.x11Window, value)
    }
  }
}

struct __SDL_WindowCreateFlags: RawRepresentable {
  init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  let rawValue: String
  
  static let alwaysOnTop = Self(rawValue: SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN)
  static let borderless = Self(rawValue: SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN)
  static let focusable = Self(rawValue: SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN)
  static let externalGraphicsContext = Self(rawValue: SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN)
  static let flags = Self(rawValue: SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER)
  static let fullscreen = Self(rawValue: SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN)
  static let height = Self(rawValue: SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER)
  static let hidden = Self(rawValue: SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN)
  static let hdpi = Self(rawValue: SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN)
  static let maximized = Self(rawValue: SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN)
  static let menu = Self(rawValue: SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN)
  static let metal = Self(rawValue: SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN)
  static let minimized = Self(rawValue: SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN)
  static let modal = Self(rawValue: SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN)
  static let grabbed = Self(rawValue: SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN)
  static let openGL = Self(rawValue: SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN)
  static let parent = Self(rawValue: SDL_PROP_WINDOW_CREATE_PARENT_POINTER)
  static let resizable = Self(rawValue: SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN)
  static let windowTitle = Self(rawValue: SDL_PROP_WINDOW_CREATE_TITLE_STRING)
  static let transparent = Self(rawValue: SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN)
  static let tooltip = Self(rawValue: SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN)
  static let utility = Self(rawValue: SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN)
  static let vulkan = Self(rawValue: SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN)
  static let width = Self(rawValue: SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER)
  static let positionX = Self(rawValue: SDL_PROP_WINDOW_CREATE_X_NUMBER)
  static let positionY = Self(rawValue: SDL_PROP_WINDOW_CREATE_Y_NUMBER)
  static let cocoaWindow = Self(rawValue: SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER)
  static let cocoaView = Self(rawValue: SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER)
  static let waylandSurfaceRoleCustom = Self(rawValue: SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN)
  static let waylandCreateEGLWindow = Self(rawValue: SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN)
  static let waylandWLSurface = Self(rawValue: SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER)
  static let win32WindowHandle = Self(rawValue: SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER)
  static let wind32PixelFormat = Self(rawValue: SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER)
  static let x11Window = Self(rawValue: SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER)
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
