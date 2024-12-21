extension SDL.Test {
  final class MouseGrid: Game {
    enum CodingKeys: CodingKey {
      case options
      case gridSize
      case circleRadius
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Simple program to test grid drawing with mouse events"
    )
    
    static let name: String = "SDL Test: Mouse Grid"

    @OptionGroup
    var options: Options
    
    @Option
    var gridSize: SDL_Size = [64, 40]
    
    @Option
    var circleRadius: Float = 10
    
    
    private var renderer: (any Renderer)!
    private var mousePos: Point<Float> = .zero
    
    func onReady(window: any Window) throws(SwiftSDL.SDL_Error) {
      try SDL_Init(.gamepad)
      
      let windowSize = try window.size(as: Float.self)
      self.renderer = try window
        .createRenderer()
        .set(
          logicalSize: windowSize,
          presentation: .stretch
        )
    }
    
    func onUpdate(window: any Window) throws(SwiftSDL.SDL_Error) {
      let logicalSize = try renderer.logicalSize.get()
      let cellSize: Size<Float> = (SDL_Size(logicalSize) / gridSize).to(Float.self)

      try renderer
        .clear(color: .gray)
        .pass(to: { renderer in
          for col in 0..<self.gridSize.x {
            for row in 0..<self.gridSize.y {
              let xPos = Float(col) * cellSize.x
              let yPos = Float(row) * cellSize.y
              
              var rect: SDL_FRect = [
                xPos, yPos,
                cellSize.x, cellSize.y
              ]
              
              let mousePos   = SDL_FPoint(self.mousePos)
              let distanceX  = abs(xPos - mousePos.x)
              let distanceY  = abs(yPos - mousePos.y)
              let distance   = (distanceX * distanceX + distanceY * distanceY).squareRoot()
              let circleArea = self.circleRadius * max(cellSize.x, cellSize.y)
              
              if distance <= circleArea {
                if distance <= circleArea / 3 {
                  try renderer.fill(rects: rect, color: 72, 72, 72, 0xF0)
                }
                else {
                  try renderer.fill(rects: rect, color: 96, 96, 96, 0xF0)
                }
              }
              
              if mousePos(SDL_PointInRectFloat, .some(&rect)) {
                try renderer.fill(rects: rect, color: 64, 64, 64, 0xFF)
              }

              try renderer
                .lines(
                  [xPos, yPos + cellSize.y],
                  [xPos, yPos],
                  [xPos + cellSize.x, yPos],
                  [xPos + cellSize.x, yPos + cellSize.y],
                  color: .white
                )
            }
          }
        })
        .present()
    }
    
    func onEvent(window: any Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      var event = event
      try renderer(SDL_ConvertEventToRenderCoordinates, .some(&event))
      switch event.eventType {
        case .mouseMotion:
          self.mousePos = event.motion.position(as: Float.self)
        default: break
      }
    }
    
    func onShutdown(window: (any Window)?) throws(SwiftSDL.SDL_Error) {
      self.renderer = nil
    }
  }
}
