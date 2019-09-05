import Clibsdl2

class WrappedPointer
{
    deinit {
        destroy(pointer: pointer)
    }
    
    func destroy(pointer: OpaquePointer) {
        /* no-op; sub-classes should override */
    }
    
    required init(pointer: OpaquePointer) {
        self.pointer = pointer
    }
    
    let pointer: OpaquePointer
}
