public protocol GPUShader: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: GPUShader { }

@discardableResult
public func SDL_Load(
  shader file: String,
  device gpuDevice: any GPUDevice,
  samplerCount: UInt32 = 0,
  uniformBufferCount: UInt32 = 0,
  storageBufferCount: UInt32 = 0,
  storageTextureCount: UInt32 = 0,
  propertyID: SDL_PropertiesID = 0,
  searchingBundles bundles: [Bundle] = Bundle.resourceBundles(),
  inDirectory directory: String? = nil) throws(SDL_Error) -> some GPUShader
{
  let stage: SDL_GPUShaderStage = file.contains(".vert") ? .vertex : .fragment
  
  var format: SDL_GPUShaderFormat = .invalid
  var entrypoint = "main"
  var fileExt = ""
  
  if gpuDevice.has(format: .spriv) {
    format = .spriv
    fileExt = ".spv"
  }
  else if gpuDevice.has(format: .msl) {
    format = .msl
    fileExt = ".msl"
    entrypoint = "main0"
  }
  else if gpuDevice.has(format: .dxil) {
    format = .dxil
    fileExt = ".dxil"
  }
  else { throw .custom("Invalid shader file extension: \(file).") }
  
  guard let filePath = bundles.compactMap({ bundle in
    bundle.path(
      forResource: file + fileExt,
      ofType: nil,
      inDirectory: directory
    )
  }).first else {
    SDL_LoadFile(nil, nil)
    throw .error
  }
  
  var codeSize = 0
  guard let code = SDL_LoadFile(filePath, &codeSize) else {
    throw .error
  }
  defer { SDL_free(code) }
  
  let codePtr = code.bindMemory(to: UInt8.self, capacity: codeSize)
  let codeBuf = UnsafeBufferPointer(start: codePtr, count: codeSize)
  
  /// This variable **must** be allocated on the stack, otherwise `SDL_CreateGPUShader`
  /// will fail with `ERROR: Creating MTLFunction failed`.
  let entrypointBytes = entrypoint.utf8CString
  
  var shaderInfo =  SDL_GPUShaderCreateInfo(
    code_size: codeSize
    , code: codeBuf.baseAddress
    , entrypoint: entrypointBytes.withUnsafeBufferPointer(\.baseAddress)
    , format: format.rawValue
    , stage: stage
    , num_samplers: samplerCount
    , num_storage_textures: storageTextureCount
    , num_storage_buffers: storageBufferCount
    , num_uniform_buffers: uniformBufferCount
    , props: propertyID
  )
  
  let pointer = try gpuDevice(SDL_CreateGPUShader, .some(&shaderInfo))
  return SDLObject(pointer, tag: .custom("\(file + fileExt)"), destroy: { [weak gpuDevice] in
    (try? gpuDevice?(SDL_ReleaseGPUShader, $0))
  })
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

extension SDL_GPUShaderStage: @retroactive Decodable, @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let vertex   = SDL_GPU_SHADERSTAGE_VERTEX
  public static let fragment = SDL_GPU_SHADERSTAGE_FRAGMENT
  
  public var debugDescription: String {
    switch self {
      case .fragment: return "fragment"
      case .vertex: return "vertex"
      default: return "Unknown SDL_GPUShaderStage: \(self)"
    }
  }
  
  public static var allCases: [SDL_GPUShaderStage] {
    [.vertex, .fragment]
  }
}
