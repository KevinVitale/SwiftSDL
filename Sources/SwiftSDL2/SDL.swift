import CSDL2
import Foundation.NSThread

public struct SDL {
    public static func initialize(subSystems: SubSystem...) throws {
        guard SDL_InitSubSystem(subSystems.reduce(0) { $0 | $1.rawValue }) == 0 else {
            throw SDLError.error(Thread.callStackSymbols)
        }
    }
    
    @inline(__always)
    public static func quit() {
        SDL_Quit()
    }
    
    @inline(__always)
    public static func quit(subSystem subSystems: SubSystem...) {
        let flags: UInt32 = subSystems.reduce(0) { $0 | $1.rawValue }
        SDL_QuitSubSystem(flags)
    }
}

public extension SDL {
    struct SubSystem: OptionSet {
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: UInt32
        
        private static let allSubSystems: [SubSystem] = [
            .audio
          , .events
          , .gameController
          , .haptic
          , .joystick
          , .sensor
          , .timer
          , .video
        ]
        
        public static let everything     = SubSystem(rawValue: SubSystem.allSubSystems.reduce(0) { $0 | $1.rawValue })
        public static let audio          = SubSystem(rawValue: SDL_INIT_AUDIO)
        public static let events         = SubSystem(rawValue: SDL_INIT_EVENTS)
        public static let gameController = SubSystem(rawValue: SDL_INIT_GAMECONTROLLER)
        public static let haptic         = SubSystem(rawValue: SDL_INIT_HAPTIC)
        public static let joystick       = SubSystem(rawValue: SDL_INIT_JOYSTICK)
        public static let sensor         = SubSystem(rawValue: SDL_INIT_SENSOR)
        public static let timer          = SubSystem(rawValue: SDL_INIT_TIMER)
        public static let video          = SubSystem(rawValue: SDL_INIT_VIDEO)
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
