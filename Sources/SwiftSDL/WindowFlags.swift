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
