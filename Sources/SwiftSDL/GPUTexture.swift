public protocol GPUTexture: SDL_ObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDL_Object<OpaquePointer>: GPUTexture { }
