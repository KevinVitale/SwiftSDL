// MARK: - Protocol
public protocol GPUDevice: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: GPUDevice { }

public func SDL_CreateGPUDevice(flags: SDL_GPUShaderFormat..., debugMode: Bool = false, named driver: String) throws(SDL_Error) -> some GPUDevice {
  try SDL_CreateGPUDevice(flags: flags, debugMode: debugMode, named: driver)
}

public func SDL_CreateGPUDevice(claimFor window: (any Window)? = nil, flags: [SDL_GPUShaderFormat] = Array(SDL_GPUShaderFormat.allCases[1...]), debugMode: Bool = false, named driver: String? = nil) throws(SDL_Error) -> some GPUDevice {
  guard let pointer =
          SDL_CreateGPUDevice(
            flags.reduce(UInt32(0)) { $0 | UInt32($1.rawValue) }
            , debugMode
            , driver
          )
  else {
    throw .error
  }
  
  let gpuDevice: SDLObject<OpaquePointer> = SDLObject(
    pointer
    , tag: .custom("gpu device (\(driver ?? "")")
    , destroy: SDL_DestroyGPUDevice
  )
  
  if let windowPointer = window?.pointer {
    try gpuDevice(SDL_ClaimWindowForGPUDevice, windowPointer)
  }
  
  return gpuDevice
}

extension GPUDevice {
  public var deviceName: Result<String, SDL_Error> {
    self
      .resultOf(SDL_GetGPUDeviceDriver)
      .map(String.init(cString:))
  }
  
  public var commandBuffer: Result<any CommandBuffer, SDL_Error> {
    self
      .resultOf(SDL_AcquireGPUCommandBuffer)
      .map { SDLObject($0, tag: .custom("command buffer")) }
  }
  
  public func render(_ commandBuffer: some CommandBuffer, pass: (OpaquePointer) throws -> Void) throws(SDL_Error) -> some GPUDevice {
      SDL_BeginGPURenderPass(commandBuffer.pointer, nil , 0 , nil )
    return self
  }
}

public enum SDL_GPUShaderFormat: RawRepresentable, Decodable, CaseIterable {
  case invalid
  case `private`
  case spriv
  case dxbc
  case dxil
  case msl
  case metallib
  
  public static var allCases: [SDL_GPUShaderFormat] {
    [
      .private
      , .spriv
      , .dxbc
      , .dxil
      , .msl
      , .metallib
    ]
  }
  
  public init?(rawValue: UInt32) {
    switch rawValue {
      case UInt32(SDL_GPU_SHADERFORMAT_PRIVATE): self = .private
      case UInt32(SDL_GPU_SHADERFORMAT_SPIRV): self = .spriv
      case UInt32(SDL_GPU_SHADERFORMAT_DXBC): self = .dxbc
      case UInt32(SDL_GPU_SHADERFORMAT_DXIL): self = .dxil
      case UInt32(SDL_GPU_SHADERFORMAT_MSL): self = .msl
      case UInt32(SDL_GPU_SHADERFORMAT_METALLIB): self = .metallib
      default: self = .invalid
    }
  }

  public var rawValue: UInt32 {
    switch self {
      case .invalid: return UInt32(SDL_GPU_SHADERFORMAT_INVALID)
      case .private: return UInt32(SDL_GPU_SHADERFORMAT_PRIVATE)
      case .spriv: return UInt32(SDL_GPU_SHADERFORMAT_SPIRV)
      case .dxbc: return UInt32(SDL_GPU_SHADERFORMAT_DXBC)
      case .dxil: return UInt32(SDL_GPU_SHADERFORMAT_DXIL)
      case .msl: return UInt32(SDL_GPU_SHADERFORMAT_MSL)
      case .metallib: return UInt32(SDL_GPU_SHADERFORMAT_METALLIB)
    }
  }
}
