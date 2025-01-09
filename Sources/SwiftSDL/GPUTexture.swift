public protocol GPUTexture: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: GPUTexture { }
