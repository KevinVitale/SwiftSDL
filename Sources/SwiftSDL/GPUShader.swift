public protocol GPUShader: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: GPUShader { }
