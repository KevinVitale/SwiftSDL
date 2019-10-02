import Foundation.NSThread
import Clibsdl2

public struct SDLPointer<T: SDLType> {
    init(pointer: OpaquePointer) {
        self._pointer = pointer
    }
    
    func destroy(pointer: OpaquePointer) {
        T.destroy(pointer: pointer)
    }
    
    let _pointer: OpaquePointer
}

public protocol SDLType {
    static func destroy(pointer: OpaquePointer)
}
