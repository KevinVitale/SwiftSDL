import Foundation.NSThread
import CSDL2

public final class SDLPointer<T: SDLType> {
    init(pointer: T.PointerType) {
        self._pointer = pointer
    }
    
    deinit {
        T.destroy(pointer: _pointer)
    }
    
    let _pointer: T.PointerType
}

public protocol SDLType {
    associatedtype PointerType
    static func destroy(pointer: PointerType)
}
