extension SDL.Test {
  final class SpinningCube: Game {
    enum CodingKeys: CodingKey {
      case options
      case msaa
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Simple program to test the SDL gpu device routines using a spinning cube"
    )

    @OptionGroup var options: Options
    
    @Flag var msaa: Bool = false
    
    private var gpuDevice: (any GPUDevice)! = nil
    private var resolveTexture: OpaquePointer? = nil

    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      self.gpuDevice = try SDL_CreateGPUDevice(claimFor: window)
      print("GPU Driver:", try gpuDevice.deviceName.get())
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      try gpuDevice
        .acquireCommandBuffer()
        .render(to: window) { swapchain in
          let colorTargetInfo = SDL_GPUColorTargetInfo(
            texture: swapchain
            , clearColor: 0.3, g: 0.4, b: 0.5
          )
          return [([colorTargetInfo], depthStencilTargetInfo: nil)]
        }
        .submit()
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      try gpuDevice?(SDL_ReleaseGPUTexture, resolveTexture)
      gpuDevice = nil
    }
  }
}
