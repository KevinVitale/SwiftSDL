import Clibsdl2

class Texture: WrappedPointer {
    /**
     Destroy the specified texture.
     */
    override func destroy(pointer: OpaquePointer) {
        SDL_DestroyTexture(pointer)
    }
    
    /**
     */
}
