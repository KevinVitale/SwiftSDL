final class GamepadNode: SpriteNodeRendered {
  var frontImage: (any Texture)!
  var rearImage: (any Texture)!
  
  var showRearImage: Bool = false
  
  override func draw(_ graphics: any Renderer) throws(SDL_Error) {
    switch showRearImage {
      case true: try graphics.draw(texture: rearImage, position: position)
      case false: try graphics.draw(texture: frontImage, position: position)
    }
    
  }
}
