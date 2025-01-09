/// SDL3 Documentation
/// https://wiki.libsdl.org/SDL3/CategoryGPU

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
  
  var deviceDriver = ""
  if let namePtr = SDL_GetGPUDeviceDriver(pointer) {
    deviceDriver = String(cString: namePtr)
  }
  
  let gpuDevice: SDLObject<OpaquePointer> = SDLObject(
    pointer
    , tag: .custom("gpu device (\(driver ?? deviceDriver))")
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
  
  public func acquireCommandBuffer() throws(SDL_Error) -> some CommandBuffer {
    try SDL_AcquireGPUCommandBuffer(with: self)
  }
  
  public func has(format: SDL_GPUShaderFormat) -> Bool {
    ((try? self(SDL_GetGPUShaderFormats) & format.rawValue) != 0)
  }
  
  public func release(shader: any GPUShader) throws(SDL_Error) {
    try self(SDL_ReleaseGPUShader, shader.pointer)
  }
  
  public func render(_ commandBuffer: some CommandBuffer, pass: (OpaquePointer) throws -> Void) throws(SDL_Error) -> some GPUDevice {
    SDL_BeginGPURenderPass(commandBuffer.pointer, nil , 0 , nil )
    return self
  }
}
