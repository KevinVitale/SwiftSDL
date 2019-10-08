import CSDL2

public extension SDL {
    enum Hint: String {
        public enum Priority: SDL_HintPriority.RawValue {
            case `default`
            case normal
            case override

            public var rawValue: SDL_HintPriority.RawValue {
                switch self {
                case .default:  return SDL_HINT_DEFAULT.rawValue
                case .normal:   return SDL_HINT_NORMAL.rawValue
                case .override: return SDL_HINT_OVERRIDE.rawValue
                }
            }
        }
        
        case accelerometerAsJoystick
        case allowTopmost
        case androidAPKExpansionMainFileVersion
        case androidAPKExpansionPatchFileVersion
        case androidBlockOnPause
        case androidTrapBackButton
        case appleTVControllerUIEvents
        case appleTVRemoteAllowRotation
        case appleTVRemoteAsJoystick
        case audioCategory
        case audioResamplingMode
        case bmpSaveLegacyFormat
        case emscriptenKeyboardElement
        case enableSteamController
        case eventLogging
        case framebufferAcceleration
        case gameControllerConfig
        case gameControllerConfigFile
        case gameControllerIgnoreDevices
        case gameControllerIgnoreDevicesExcept
        case grabKeyboard
        case idleTimerDisabled
        case imeInternalEditing
        case imeReturnKeyDoesHide
        case iosHideHomeIndicator
        case joystickAllowBackgroundEvents
        case joystickHIDApi
        case joystickHIDApiPS4
        case joystickHIDApiPS4Rumble
        case joystickHIDApiSteam
        case joystickHIDApiSwitch
        case joystickHIDApiXbox
        case macBackgroundApp
        case macCTRLClickEmulateRightClick
        case mouseDoubleClickRadius
        case mouseDoubleClickTime
        case mouseFocusClickthrough
        case mouseNormalSpeedScale
        case mouseRelativeModeWarp
        case mouseRelativeSpeedScale
        case mouseTouchEvents
        case noSignalHandlers
        case openGLESDriver
        case orientations
        case qtWaylandContentOrientation
        case qtWaylandWindowFlags
        case renderBatching
        case renderDirect3D11Debug
        case renderDirect3DThreadSafe
        case renderDriver
        case renderLogicalSizeMode
        case renderOpenGLShaders
        case renderScaleQuality
        case renderVSync
        case rpiVideoLayer
        case threadStackSize
        case timerResolution
        case touchMouseEvents
        case tvRemoteAsJoystick
        case videoAllowScreenSaver
        case videoDoubleBuffer
        case videoHighDPIDisabled
        case videoMacFullscreenSpaces
        case videoMinimizeOnFocusLoss
        case videoWinD3DCompiler
        case videoWindowSharePixelFormat
        case videoX11NetWMBypassCompositor
        case videoX11NetWMPing
        case videoX11XRandR
        case videoX11XVIDMode
        case videoX11Xinerama
        case waveFactChunk
        case waveRiffChunkSize
        case waveTruncation
        case winRTHandleBackButton
        case winRTPrivacyPolicyLabel
        case winRTPrivacyPolicyURL
        case windowFrameUsableWhileCursorHidden
        case windowsDisableThreadNaming
        case windowsEnableMessageLoop
        case windowsIntersourceIcon
        case windowsIntersourceIconSmall
        case windowsNoCloseOnAltF4
        case xinputEnabled
        case xinputUseOldJoystickMapping

        public var rawValue: String {
            switch self {
            case .framebufferAcceleration:
                return SDL_HINT_FRAMEBUFFER_ACCELERATION
            case .renderDriver:
                return SDL_HINT_RENDER_DRIVER
            case .renderOpenGLShaders:
                return SDL_HINT_RENDER_OPENGL_SHADERS
            case .renderDirect3DThreadSafe:
                return SDL_HINT_RENDER_DIRECT3D_THREADSAFE
            case .renderDirect3D11Debug:
                return SDL_HINT_RENDER_DIRECT3D11_DEBUG
            case .renderLogicalSizeMode:
                return SDL_HINT_RENDER_LOGICAL_SIZE_MODE
            case .renderScaleQuality:
                return SDL_HINT_RENDER_SCALE_QUALITY
            case .renderVSync:
                return SDL_HINT_RENDER_VSYNC
            case .videoAllowScreenSaver:
                return SDL_HINT_VIDEO_ALLOW_SCREENSAVER
            case .videoX11XVIDMode:
                return SDL_HINT_VIDEO_X11_XVIDMODE
            case .videoX11Xinerama:
                return SDL_HINT_VIDEO_X11_XINERAMA
            case .videoX11XRandR:
                return SDL_HINT_VIDEO_X11_XRANDR
            case .videoX11NetWMPing:
                return SDL_HINT_VIDEO_X11_NET_WM_PING
            case .videoX11NetWMBypassCompositor:
                return SDL_HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR
            case .windowFrameUsableWhileCursorHidden:
                return SDL_HINT_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN
            case .windowsIntersourceIcon:
                return SDL_HINT_WINDOWS_INTRESOURCE_ICON
            case .windowsIntersourceIconSmall:
                return SDL_HINT_WINDOWS_INTRESOURCE_ICON_SMALL
            case .windowsEnableMessageLoop:
                return SDL_HINT_WINDOWS_ENABLE_MESSAGELOOP
            case .grabKeyboard:
                return SDL_HINT_GRAB_KEYBOARD
            case .mouseDoubleClickTime:
                return SDL_HINT_MOUSE_DOUBLE_CLICK_TIME
            case .mouseDoubleClickRadius:
                return SDL_HINT_MOUSE_DOUBLE_CLICK_RADIUS
            case .mouseNormalSpeedScale:
                return SDL_HINT_MOUSE_NORMAL_SPEED_SCALE
            case .mouseRelativeSpeedScale:
                return SDL_HINT_MOUSE_RELATIVE_SPEED_SCALE
            case .mouseRelativeModeWarp:
                return SDL_HINT_MOUSE_RELATIVE_MODE_WARP
            case .mouseFocusClickthrough:
                return SDL_HINT_MOUSE_FOCUS_CLICKTHROUGH
            case .mouseTouchEvents:
                return SDL_HINT_MOUSE_TOUCH_EVENTS
            case .touchMouseEvents:
                return SDL_HINT_TOUCH_MOUSE_EVENTS
            case .videoMinimizeOnFocusLoss:
                return SDL_HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS
            case .idleTimerDisabled:
                return SDL_HINT_IDLE_TIMER_DISABLED
            case .orientations:
                return SDL_HINT_ORIENTATIONS
            case .appleTVControllerUIEvents:
                return SDL_HINT_APPLE_TV_CONTROLLER_UI_EVENTS
            case .appleTVRemoteAllowRotation:
                return SDL_HINT_APPLE_TV_REMOTE_ALLOW_ROTATION
            case .appleTVRemoteAsJoystick: fallthrough
            case .tvRemoteAsJoystick:
                return SDL_HINT_TV_REMOTE_AS_JOYSTICK
            case .iosHideHomeIndicator:
                return SDL_HINT_IOS_HIDE_HOME_INDICATOR
            case .accelerometerAsJoystick:
               return SDL_HINT_ACCELEROMETER_AS_JOYSTICK
            case .xinputEnabled:
                return SDL_HINT_XINPUT_ENABLED
            case .xinputUseOldJoystickMapping:
                return SDL_HINT_XINPUT_USE_OLD_JOYSTICK_MAPPING
            case .gameControllerConfig:
                return SDL_HINT_GAMECONTROLLERCONFIG
            case .gameControllerConfigFile:
                return SDL_HINT_GAMECONTROLLERCONFIG_FILE
            case .gameControllerIgnoreDevices:
                return SDL_HINT_GAMECONTROLLER_IGNORE_DEVICES
            case .gameControllerIgnoreDevicesExcept:
                return SDL_HINT_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT
            case .joystickAllowBackgroundEvents:
                return SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS
            case .joystickHIDApi:
               return SDL_HINT_JOYSTICK_HIDAPI
            case .joystickHIDApiPS4:
                return SDL_HINT_JOYSTICK_HIDAPI_PS4
            case .joystickHIDApiPS4Rumble:
                return SDL_HINT_JOYSTICK_HIDAPI_PS4_RUMBLE
            case .joystickHIDApiSteam:
                return SDL_HINT_JOYSTICK_HIDAPI_STEAM
            case .joystickHIDApiSwitch:
                return SDL_HINT_JOYSTICK_HIDAPI_SWITCH
            case .joystickHIDApiXbox:
                return SDL_HINT_JOYSTICK_HIDAPI_XBOX
            case .enableSteamController:
                return SDL_HINT_ENABLE_STEAM_CONTROLLERS
            case .allowTopmost:
                return SDL_HINT_ALLOW_TOPMOST
            case .timerResolution:
                return SDL_HINT_TIMER_RESOLUTION
            case .qtWaylandContentOrientation:
                return SDL_HINT_QTWAYLAND_CONTENT_ORIENTATION
            case .qtWaylandWindowFlags:
                return SDL_HINT_QTWAYLAND_WINDOW_FLAGS
            case .threadStackSize:
                return SDL_HINT_THREAD_STACK_SIZE
            case .videoHighDPIDisabled:
                return SDL_HINT_VIDEO_HIGHDPI_DISABLED
            case .macCTRLClickEmulateRightClick:
                return SDL_HINT_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK
            case .videoWinD3DCompiler:
                return SDL_HINT_VIDEO_WIN_D3DCOMPILER
            case .videoWindowSharePixelFormat:
                return SDL_HINT_VIDEO_WINDOW_SHARE_PIXEL_FORMAT
            case .winRTPrivacyPolicyURL:
                return SDL_HINT_WINRT_PRIVACY_POLICY_URL
            case .winRTPrivacyPolicyLabel:
                return SDL_HINT_WINRT_PRIVACY_POLICY_LABEL
            case .winRTHandleBackButton:
                return SDL_HINT_WINRT_HANDLE_BACK_BUTTON
            case .videoMacFullscreenSpaces:
                return SDL_HINT_VIDEO_MAC_FULLSCREEN_SPACES
            case .macBackgroundApp:
                return SDL_HINT_MAC_BACKGROUND_APP
            case .androidAPKExpansionMainFileVersion:
                return SDL_HINT_ANDROID_APK_EXPANSION_MAIN_FILE_VERSION
            case .androidAPKExpansionPatchFileVersion:
                return SDL_HINT_ANDROID_APK_EXPANSION_PATCH_FILE_VERSION
            case .androidTrapBackButton:
                return SDL_HINT_ANDROID_TRAP_BACK_BUTTON
            case .androidBlockOnPause:
                return SDL_HINT_ANDROID_BLOCK_ON_PAUSE
            case .imeInternalEditing:
                return SDL_HINT_IME_INTERNAL_EDITING
            case .imeReturnKeyDoesHide:
                return SDL_HINT_RETURN_KEY_HIDES_IME
            case .emscriptenKeyboardElement:
                return SDL_HINT_EMSCRIPTEN_KEYBOARD_ELEMENT
            case .noSignalHandlers:
                return SDL_HINT_NO_SIGNAL_HANDLERS
            case .windowsNoCloseOnAltF4:
                return SDL_HINT_WINDOWS_NO_CLOSE_ON_ALT_F4
            case .bmpSaveLegacyFormat:
                return SDL_HINT_BMP_SAVE_LEGACY_FORMAT
            case .windowsDisableThreadNaming:
                return SDL_HINT_WINDOWS_DISABLE_THREAD_NAMING
            case .rpiVideoLayer:
                return SDL_HINT_RPI_VIDEO_LAYER
            case .videoDoubleBuffer:
                return SDL_HINT_VIDEO_DOUBLE_BUFFER
            case .openGLESDriver:
                return SDL_HINT_OPENGL_ES_DRIVER
            case .audioResamplingMode:
                return SDL_HINT_AUDIO_RESAMPLING_MODE
            case .renderBatching:
                return SDL_HINT_RENDER_BATCHING
            case .eventLogging:
                return SDL_HINT_EVENT_LOGGING
            case .waveRiffChunkSize:
                return SDL_HINT_WAVE_RIFF_CHUNK_SIZE
            case .waveTruncation:
                return SDL_HINT_WAVE_TRUNCATION
            case .waveFactChunk:
                return SDL_HINT_WAVE_FACT_CHUNK
            case .audioCategory:
                return SDL_HINT_AUDIO_CATEGORY
            }
        }
        
        private func set(_ value: String, priority: Priority) -> Bool {
            self.rawValue.withCString({ h in
                value.withCString { v in
                    SDL_SetHintWithPriority(h, v, SDL_HintPriority(rawValue: priority.rawValue))
                }
            }) == SDL_TRUE
        }
        
        private func query() -> String? {
            rawValue
                .withCString({ SDL_GetHint($0) })
                .map(String.init)
        }
        
        public static subscript(hint: Hint) -> String? {
            hint.query()
        }
        
        public static func clear() {
            SDL_ClearHints()
        }
        
        @discardableResult
        public static func set(_ value: String, for hint: Hint, priority: Priority = .normal) -> Bool {
            hint.set(value, priority: priority)
        }
    }
}
