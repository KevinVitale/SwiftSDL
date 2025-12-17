// MARK: - Renderer Protocol
public protocol Renderer: SDL_ObjectProtocol, Sendable where Pointer == OpaquePointer {
}

// MARK: - SDL_Object Conformance
extension SDL_Object<OpaquePointer>: Renderer { }

// MARK: - Window Extension
extension Window {
  /**
   - parameter driverName: one of the strings returned by `SDL_GetRenderDriver`, or `nil` to auto-select.
   - parameter retain:
     - When `true`, returns an instance with a `+1` retain count.
     This **must** be balanced with a `destroy()` at a later time (such as `GameLoop.onShutdown(_:_:)`),
     otherwise the instance leaks.
     - When `false`, the returned instance will be released immediately, unless an expression (such as a property assignment)
     explicitly retains the instance beyond the scope of the caller.
   
   - seealso: `SDL_CreateRenderer`
   */
  @discardableResult
  public func createRenderer(using driverName: String? = nil, retain: Bool = false) throws(SDL_Error) -> any Renderer {
    guard let renderer = __SDL_CreateRenderer(pointer, driverName?.cString(using: .utf8) ?? nil) else {
      throw .error
    }
    return SDL_Object(renderer, tag: "renderer (retain: \(retain))", destroy: retain ? { _ in  } : SDL_DestroyRenderer)
  }
  
  public func createRenderer(properties: SDL_RendererCreateProperty..., retain: Bool = false) throws(SDL_Error) -> any Renderer {
    try self.createRenderer(properties: properties, retain: retain)
  }
  
  public func createRenderer(properties: [SDL_RendererCreateProperty], retain: Bool = false) throws(SDL_Error) -> any Renderer {
    let pointer = UnsafeMutableRawPointer(self.pointer)
    let properties = try SDL_PropertiesID.init(properties: properties + [.window(pointer)])
    
    guard let renderer = __SDL_CreateRendererWithProperties(properties.id) else {
      throw .error
    }
    
    return SDL_Object(renderer, tag: "renderer (retain: \(retain))", destroy: retain ? { _ in  } : SDL_DestroyRenderer)
  }
}

// MARK: - Driver Query
public func SDL_GetRenderDriver() -> [String] {
  (0..<SDL_GetNumRenderDrivers())
    .compactMap(__SDL_GetRenderDriver)
    .map(String.init(cString:))
}

// MARK: - Core
extension Renderer {
  /**
   - seealso: `SDL_GetRendererName`
   */
  public var name: Result<String, SDL_Error> {
    return self
      .resultOf(SDL_GetRendererName)
      .map({ String(cString: $0) })
  }

  /**
   - seealso: `SDL_RenderPresent`
   */
  @discardableResult
  public func present() throws(SDL_Error) -> Self {
    try self(SDL_RenderPresent)
  }
  
  /**
   - note: Used as a _release_, to balance a _retain_ if specified during **create** (_e.g.,_ `window.createRenderer(retain: true)`).
   - seealso: `SDL_DestroyRenderer`.
   */
  public func destroy() throws(SDL_Error) {
    try self(SDL_DestroyRenderer)
  }
  
  /**
   Use this to pass the renderer object into a closure, or other functions, while continuing
   to chain methods in a declarative manner.
   */
  @discardableResult
  public func pass<each Argument>(to callback: (_ renderer: Self, repeat each Argument) throws(SDL_Error) -> Void, _ argument: repeat each Argument) throws(SDL_Error) -> Self {
    try callback(self, repeat each argument)
    return self
  }
}

// MARK: Core (Result)
extension Result where Success == any Renderer, Failure == SDL_Error {
  /**
   - note: Used as a _release_, to balance a _retain_ if specified during **create** (_e.g.,_ `window.createRenderer(retain: true)`).
   - seealso: `SDL_DestroyRenderer`.
   */
  @discardableResult
  public func destroy() -> Result<(), Failure> {
    flatMap { $0.resultOf(SDL_DestroyRenderer) }
  }
}

// MARK: Sizing & Presentation
extension Renderer {
  /**
   - seealso: `SDL_GetRenderViewport`
   */
  public var viewport: Result<Rect<Int32>, SDL_Error> {
    var rect = SDL_Rect()
    return self
      .resultOf(SDL_GetRenderViewport, .some(&rect))
      .map({ _ in [rect.x, rect.y, rect.w, rect.h] })
  }
  
  /**
   - seealso: `SDL_GetRenderSafeArea`
   */
  public var safeArea: Result<Rect<Int32>, SDL_Error> {
    var rect = SDL_Rect()
    return self
      .resultOf(SDL_GetRenderSafeArea, .some(&rect))
      .map({ _ in [rect.x, rect.y, rect.w, rect.h] })
  }
  
  /**
   - seealso: `SDL_GetRenderLogicalPresentation`
   */
  public var logicalSize: Result<Size<Int32>, SDL_Error> {
    var width: Int32 = 0, height: Int32 = 0
    return self
      .resultOf(SDL_GetRenderLogicalPresentation, .some(&width), .some(&height), nil)
      .map({ _ in [width, height] })
  }
  
  /**
   - seealso: `SDL_GetRenderLogicalPresentation`
   */
  public var logicalPresentation: Result<SDL_RendererLogicalPresentation, SDL_Error> {
    var mode: SDL_RendererLogicalPresentation = .disabled
    return self
      .resultOf(SDL_GetRenderLogicalPresentation, nil, nil, .some(&mode))
      .map({ _ in mode })
  }
}

// MARK: - Blend Mode
extension Renderer {
  @available(*, deprecated)
  public var blendMode: Result<SDL_BlendMode, SDL_Error> {
    var blendMode: SDL_BlendMode.RawValue = 0
    return self
      .resultOf(SDL_GetRenderDrawBlendMode, .some(&blendMode))
      .map({ _ in SDL_BlendMode(rawValue: blendMode) ?? .invalid })
  }

  @available(*, deprecated)
  @discardableResult
  public func set(blendMode: SDL_BlendMode) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderDrawBlendMode, blendMode.rawValue)
  }
}

// MARK: - VSync
extension Renderer {
  @available(*, deprecated)
  public var vsync: Result<Int32, SDL_Error> {
    var vsync: Int32 = 0
    return self
      .resultOf(SDL_GetRenderVSync, .some(&vsync))
      .map({ _ in vsync })
  }
  
  @discardableResult
  public func set(vsync: Int32) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderVSync, vsync)
  }
}


extension SDL_PropertiesID {
  public convenience init(id: ID? = nil, properties: SDL_RendererCreateProperty...) throws(SDL_Error) {
    try self.init(id: id, properties: properties)
  }
  
  public convenience init(id: ID? = nil, properties: [SDL_RendererCreateProperty]) throws(SDL_Error) {
    try self.init(id: id,  properties: properties.map { ($0.property, $0.wrappedValue) })
  }
}

// MARK: RendererCreateProperty Struct
@propertyWrapper
public enum SDL_RendererCreateProperty {
  case name(String)
  case window(UnsafeMutableRawPointer)
  case surface(UnsafeMutableRawPointer)
  case outputColorspace(Sint64)
  case presentVsync(Sint64)
  case vulkanInstance(UnsafeMutableRawPointer)
  case vulkanSurface(Sint64)
  case vulkanPhysicalDevice(UnsafeMutableRawPointer)
  case vulkanDevice(UnsafeMutableRawPointer)
  case vulkanGraphicsQueueFamilyIndex(Sint64)
  case vulkanPresentQueueFamilyIndex(Sint64)
  
  public var property: String {
    switch self {
      case .name: return SDL_PROP_RENDERER_CREATE_NAME_STRING
      case .window: return SDL_PROP_RENDERER_CREATE_WINDOW_POINTER
      case .surface: return SDL_PROP_RENDERER_CREATE_SURFACE_POINTER
      case .outputColorspace: return SDL_PROP_RENDERER_CREATE_OUTPUT_COLORSPACE_NUMBER
      case .presentVsync: return SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER
      case .vulkanInstance: return SDL_PROP_RENDERER_CREATE_VULKAN_INSTANCE_POINTER
      case .vulkanSurface: return SDL_PROP_RENDERER_CREATE_VULKAN_SURFACE_NUMBER
      case .vulkanPhysicalDevice: return SDL_PROP_RENDERER_CREATE_VULKAN_PHYSICAL_DEVICE_POINTER
      case .vulkanDevice: return SDL_PROP_RENDERER_CREATE_VULKAN_DEVICE_POINTER
      case .vulkanGraphicsQueueFamilyIndex: return SDL_PROP_RENDERER_CREATE_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER
      case .vulkanPresentQueueFamilyIndex: return SDL_PROP_RENDERER_CREATE_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER
    }
  }
  
  public var wrappedValue: (any SDL_PropertyTypeValue) {
    switch self {
      case .name(let value): return value
      case .window(let value): return value
      case .surface(let value): return value
      case .outputColorspace(let value): return value
      case .presentVsync(let value): return value
      case .vulkanInstance(let value): return value
      case .vulkanSurface(let value): return value
      case .vulkanPhysicalDevice(let value): return value
      case .vulkanDevice(let value): return value
      case .vulkanGraphicsQueueFamilyIndex(let value): return value
      case .vulkanPresentQueueFamilyIndex(let value): return value
    }
  }
}

// MARK: - Renderer Properties
extension Renderer {
  public var properties: Result<SDL_PropertiesID, SDL_Error> {
    self.resultOf(SDL_GetRendererProperties)
      .flatMap { propertyID in
        Result { try SDL_PropertiesID(id: propertyID) }
          .mapError { $0 as! SDL_Error }
      }
  }
}

// MARK: Subscripts
extension SDL_PropertiesID {
  public subscript(property: SDL_RendererProperty) -> (any SDL_PropertyTypeValue)? {
    self[property.property]
  }
}

extension Result where Success == SDL_PropertiesID, Failure == SDL_Error {
  public subscript(property: SDL_RendererProperty) -> Result<(any SDL_PropertyTypeValue)?, Failure> {
    map { $0[property.property] }
  }
}

// MARK: RendererProperty Struct
@propertyWrapper
public enum SDL_RendererProperty {
  case name
  case window
  case surface
  case vsync
  case maxTextureSize
  case textureFormats
  case outputColorspace
  case hdrEnabled
  case sdrWhitePoint
  case hdrHeadroom
  case d3d9Device
  case d3d11Device
  case d3d11Swapchain
  case d3d12Device
  case d3d12Swapchain
  case d3d12CommandQueue
  case vulkanInstance
  case vulkanSurface
  case vulkanPhysicalDevice
  case vulkanDevice
  case vulkanGraphicsQueueFamilyIndex
  case vulkanPresentQueueFamilyIndex
  case vulkanSwapchain
  case vulkanGPUDevice
  
  public var wrappedValue: (any SDL_PropertyTypeValue) {
    switch self {
      case .name: fatalError()
      case .window: fatalError()
      case .surface: fatalError()
      case .vsync: fatalError()
      case .maxTextureSize: fatalError()
      case .textureFormats: fatalError()
      case .outputColorspace: fatalError()
      case .hdrEnabled: fatalError()
      case .sdrWhitePoint: fatalError()
      case .hdrHeadroom: fatalError()
      case .d3d9Device: fatalError()
      case .d3d11Device: fatalError()
      case .d3d11Swapchain: fatalError()
      case .d3d12Device: fatalError()
      case .d3d12Swapchain: fatalError()
      case .d3d12CommandQueue: fatalError()
      case .vulkanInstance: fatalError()
      case .vulkanSurface: fatalError()
      case .vulkanPhysicalDevice: fatalError()
      case .vulkanDevice: fatalError()
      case .vulkanGraphicsQueueFamilyIndex: fatalError()
      case .vulkanPresentQueueFamilyIndex: fatalError()
      case .vulkanSwapchain: fatalError()
      case .vulkanGPUDevice: fatalError()
    }
  }

  public var property: String {
    switch self {
      case .name: return SDL_PROP_RENDERER_NAME_STRING
      case .window: return SDL_PROP_RENDERER_WINDOW_POINTER
      case .surface: return SDL_PROP_RENDERER_SURFACE_POINTER
      case .vsync: return SDL_PROP_RENDERER_VSYNC_NUMBER
      case .maxTextureSize: return SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER
      case .textureFormats: return SDL_PROP_RENDERER_TEXTURE_FORMATS_POINTER
      case .outputColorspace: return SDL_PROP_RENDERER_OUTPUT_COLORSPACE_NUMBER
      case .hdrEnabled: return SDL_PROP_RENDERER_HDR_ENABLED_BOOLEAN
      case .sdrWhitePoint: return SDL_PROP_RENDERER_SDR_WHITE_POINT_FLOAT
      case .hdrHeadroom: return SDL_PROP_RENDERER_HDR_HEADROOM_FLOAT
      case .d3d9Device: return SDL_PROP_RENDERER_D3D9_DEVICE_POINTER
      case .d3d11Device: return SDL_PROP_RENDERER_D3D11_DEVICE_POINTER
      case .d3d11Swapchain: return SDL_PROP_RENDERER_D3D11_SWAPCHAIN_POINTER
      case .d3d12Device: return SDL_PROP_RENDERER_D3D12_DEVICE_POINTER
      case .d3d12Swapchain: return SDL_PROP_RENDERER_D3D12_SWAPCHAIN_POINTER
      case .d3d12CommandQueue: return SDL_PROP_RENDERER_D3D12_COMMAND_QUEUE_POINTER
      case .vulkanInstance: return SDL_PROP_RENDERER_VULKAN_INSTANCE_POINTER
      case .vulkanSurface: return SDL_PROP_RENDERER_VULKAN_SURFACE_NUMBER
      case .vulkanPhysicalDevice: return SDL_PROP_RENDERER_VULKAN_PHYSICAL_DEVICE_POINTER
      case .vulkanDevice: return SDL_PROP_RENDERER_VULKAN_DEVICE_POINTER
      case .vulkanGraphicsQueueFamilyIndex: return SDL_PROP_RENDERER_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER
      case .vulkanPresentQueueFamilyIndex: return SDL_PROP_RENDERER_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER
      case .vulkanSwapchain: return SDL_PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER
      case .vulkanGPUDevice: return SDL_PROP_RENDERER_GPU_DEVICE_POINTER
    }
  }
  
}

