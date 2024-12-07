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
      gpuDevice = try SDL_CreateGPUDevice(claimFor: window)
      print("GPU Driver:", try gpuDevice.deviceName.get())
      throw .custom("This is a custom error")
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      try gpuDevice?(SDL_ReleaseGPUTexture, resolveTexture)
      gpuDevice = nil
    }
  }
}
