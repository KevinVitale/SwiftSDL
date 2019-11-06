import CSDL2
import Foundation

public struct SDL {
    public final class Engine {
        public typealias InputHandler   = () -> ()
        public typealias UpdateCallback = (_ deltaTime: TimeInterval) -> ()
        public typealias RenderCallback = () -> ()
        
        private var subsystems: [SDLSubsystem] = []
        private var    windows: [SDLWindow] = []
        
        public private(set) var isRunning: Bool = false
        
        public var handleInput: InputHandler   = { }
        public var      update: UpdateCallback = { _ in }
        public var      render: RenderCallback = { }
        
        public var version: SDL_version {
            var version = SDL_version()
            SDL_GetVersion(&version)
            return version
        }
        
        public func start(subsystems: SDLSubsystem...) throws {
            guard SDL_InitSubSystem(subsystems.reduce(0) { $0 | $1.rawValue }) == 0 else {
                throw SDLError.error(Thread.callStackSymbols)
            }
            self.subsystems = subsystems
            self.isRunning = true
        }
        
        public func stop() {
            self.isRunning = false
        }
        
        func quit(_ status: Int32) -> Never {
            let flags: UInt32 = self.subsystems.reduce(0) { $0 | $1.rawValue }
            SDL_QuitSubSystem(flags)
            exit(status)
        }
        
        public func addWindow(title: String, width: Int32, height: Int32, windowFlags: SDLWindow.Flag = [], renderFlags: SDLRenderer.Flag = []) throws -> SDLRenderer {
            var window: SDLWindow!
            var renderer: SDLRenderer!
            
            switch renderFlags.isEmpty {
            case true:
                window = try SDLWindow(title: title, renderer: &renderer, width: width, height: height, flags: windowFlags)
            case false:
                window = try SDLWindow(title: title, width: width, height: height, flags: windowFlags)
                renderer = window
                    .pass(to: SDL_CreateRenderer, -1, .renderFlags(renderFlags))
                    .map(SDLRenderer.init)
            }
            
            // Keep a reference to 'window' ------------------------------------
            self.windows.append(window)
            
            // Return 'renderer' -----------------------------------------------
            return renderer
        }
        
        public func removeWindow(titled title: String) {
            let matchingWindows = self.windows
                .compactMap({ ($0, $0.pass(to: SDL_GetWindowTitle).map(String.init)) })
                .filter({ $0.1 == title })
                .map({ $0.0 })
            
            // Remove all windows matching 'title' -----------------------------
            self.windows.removeAll(where: {
                matchingWindows.contains($0)
            })
        }
        
        public func window(named name: String) -> SDLWindow? {
            self.windows
                .filter({ $0.pass(to: SDL_GetWindowTitle).map(String.init) == name })
                .first
        }
    }
}

public extension SDL {
    struct SDLSubsystem: OptionSet {
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: UInt32
        
        private static let allSubSystems: [SDLSubsystem] = [
            .audio
          , .events
          , .gameController
          , .haptic
          , .joystick
          // , .sensor
          , .timer
          , .video
        ]
        
        public static let everything     = SDLSubsystem(rawValue: SDLSubsystem.allSubSystems.reduce(0) { $0 | $1.rawValue })
        public static let audio          = SDLSubsystem(rawValue: SDL_INIT_AUDIO)
        public static let events         = SDLSubsystem(rawValue: SDL_INIT_EVENTS)
        public static let gameController = SDLSubsystem(rawValue: SDL_INIT_GAMECONTROLLER)
        public static let haptic         = SDLSubsystem(rawValue: SDL_INIT_HAPTIC)
        public static let joystick       = SDLSubsystem(rawValue: SDL_INIT_JOYSTICK)
        // public static let sensor         = SDLSubsystem(rawValue: SDL_INIT_SENSOR)
        public static let timer          = SDLSubsystem(rawValue: SDL_INIT_TIMER)
        public static let video          = SDLSubsystem(rawValue: SDL_INIT_VIDEO)
    }
}

public extension SDL {
    struct Version {
        public static var current: SDL_version {
            get {
                var version: SDL_version = SDL_version()
                SDL_GetVersion(&version)
                return version
            }
        }
    }
}

extension SDL_Color {
    func mapRGB(format: UnsafeMutablePointer<SDL_PixelFormat>!) -> UInt32 {
        return SDL_MapRGB(format, self.r, self.g, self.b)
    }
    
    func mapRGBA(format: UnsafeMutablePointer<SDL_PixelFormat>!) -> UInt32 {
        return SDL_MapRGBA(format, self.r, self.g, self.b, self.a)
    }
}
